require "test_helper"

class ObjectTest < Minitest::Test
  def test_creating_object_from_hash
    assert_equal "bar", FreeAgent::Object.new(foo: "bar").foo
  end

  def test_nested_hash
    assert_equal "foobar", FreeAgent::Object.new(foo: { bar: { baz: "foobar" } }).foo.bar.baz
  end

  def test_nested_number
    assert_equal 1, FreeAgent::Object.new(foo: { bar: 1 }).foo.bar
  end

  def test_array
    object = FreeAgent::Object.new(foo: [ { bar: :baz } ])
    assert_equal FreeAgent::Object, object.foo.first.class
    assert_equal :baz, object.foo.first.bar
  end

  class Money < FreeAgent::Object
    decimal_attributes :total_value, :paid_value
  end

  def test_id_is_generated_from_the_url
    object = FreeAgent::Object.new("url" => "https://api.freeagent.com/v2/contacts/12345")
    assert_equal "12345", object.id
  end

  def test_nested_objects_get_an_id_from_their_url
    object = FreeAgent::Object.new("items" => [ { "url" => "https://api.freeagent.com/v2/attachments/33" } ])
    assert_equal "33", object.items.first.id
  end

  def test_decimal_attributes_are_coerced_to_floats
    object = Money.new("total_value" => "200.0", "paid_value" => "-50.25")

    assert_equal 200.0, object.total_value
    assert_equal(-50.25, object.paid_value)
  end

  def test_decimal_attributes_leave_other_attributes_alone
    object = Money.new("total_value" => "200.0", "exchange_rate" => "1.0")

    assert_equal "1.0", object.exchange_rate
  end

  def test_decimal_attributes_tolerate_missing_and_blank_values
    object = Money.new("total_value" => "")

    assert_equal "", object.total_value
    assert_nil object.paid_value
  end

  def test_decimal_attributes_are_not_inherited_by_unrelated_objects
    assert_equal [], FreeAgent::Object.decimal_attribute_names
    assert_equal "200.0", FreeAgent::Object.new("total_value" => "200.0").total_value
  end

  def test_empty_hash
    object = FreeAgent::Object.new({})
    refute_nil object
  end

  def test_nil_values
    object = FreeAgent::Object.new(foo: nil, bar: "baz")
    assert_nil object.foo
    assert_equal "baz", object.bar
  end

  def test_boolean_values
    object = FreeAgent::Object.new(is_live: true, is_mature: false)
    assert_equal true, object.is_live
    assert_equal false, object.is_mature
  end

  def test_mixed_array_types
    object = FreeAgent::Object.new(data: [ "string", 123, { nested: "value" }, true ])
    assert_equal "string", object.data[0]
    assert_equal 123, object.data[1]
    assert_equal "value", object.data[2].nested
    assert_equal true, object.data[3]
  end

  def test_deeply_nested_structure
    complex_data = {
      user: {
        id: "123",
        profile: {
          settings: {
            notifications: {
              email: true,
              push: false
            }
          }
        }
      }
    }
    object = FreeAgent::Object.new(complex_data)
    assert_equal "123", object.user.id
    assert_equal true, object.user.profile.settings.notifications.email
    assert_equal false, object.user.profile.settings.notifications.push
  end

  def test_string_keys_and_symbol_keys
    object = FreeAgent::Object.new("string_key" => "value1", symbol_key: "value2")
    assert_equal "value1", object.string_key
    assert_equal "value2", object.symbol_key
  end

  def test_to_h_converts_nested_objects_to_hashes
    object = FreeAgent::Object.new("id" => "1", "settings" => { "slow_mode" => true }, "items" => [ { "a" => 1 }, 2 ])

    assert_equal({ id: "1", settings: { slow_mode: true }, items: [ { a: 1 }, 2 ] }, object.to_h)
  end

  def test_to_h_with_block
    object = FreeAgent::Object.new("id" => "1", "name" => "test")

    assert_equal({ "id" => "1", "name" => "test" }, object.to_h { |key, value| [ key.to_s, value ] })
  end

  def test_to_json_serializes_nested_objects
    object = FreeAgent::Object.new("id" => "1", "settings" => { "slow_mode" => true }, "items" => [ { "a" => 1 } ])

    assert_equal({ "id" => "1", "settings" => { "slow_mode" => true }, "items" => [ { "a" => 1 } ] }, JSON.parse(object.to_json))
  end

  def test_to_json_works_inside_other_structures
    users = [ FreeAgent::Contact.new("id" => "1", "images" => { "profile" => "url" }) ]

    assert_equal [ { "id" => "1", "images" => { "profile" => "url" } } ], JSON.parse(users.to_json)
  end

  def test_as_json_returns_nested_hash
    object = FreeAgent::Object.new("settings" => { "slow_mode" => true })

    assert_equal({ settings: { slow_mode: true } }, object.as_json)
  end

  def test_hash_access
    object = FreeAgent::Object.new("id" => "141981764")
    assert_equal "141981764", object[:id]
    assert_equal "141981764", object["id"]
  end

  def test_missing_attribute_returns_nil
    object = FreeAgent::Object.new(foo: "bar")
    assert_nil object.baz
    refute object.respond_to?(:baz)
    assert object.respond_to?(:foo)
  end

  def test_setting_attributes
    object = FreeAgent::Object.new(foo: "bar")
    object.foo = "baz"
    object[:qux] = { quux: 1 }
    assert_equal "baz", object.foo
    assert_equal 1, object.qux.quux
  end

  def test_attributes_named_after_private_methods
    object = FreeAgent::Object.new(format: "mp4", test: true, type: "live")
    assert_equal "mp4", object.format
    assert_equal true, object.test
    assert_equal "live", object.type
  end

  def test_unknown_method_with_arguments_raises
    assert_raises(NoMethodError) { FreeAgent::Object.new(foo: "bar").foo(1) }
  end

  def test_dig
    object = FreeAgent::Object.new(data: [ { images: { url_1x: "https://example.com/1x.png" } } ])
    assert_equal "https://example.com/1x.png", object.dig(:data, 0, :images, :url_1x)
    assert_nil object.dig(:missing, :id)
  end

  def test_each_pair
    object = FreeAgent::Object.new(id: "1", login: "twitchdev")
    assert_equal [ [ :id, "1" ], [ :login, "twitchdev" ] ], object.each_pair.to_a
  end

  def test_equality
    assert_equal FreeAgent::Object.new(foo: { bar: 1 }), FreeAgent::Object.new("foo" => { "bar" => 1 })
    refute_equal FreeAgent::Object.new(foo: 1), FreeAgent::Object.new(foo: 2)
  end

  def test_inspect
    assert_equal '#<FreeAgent::Contact id="1">', FreeAgent::Contact.new(id: "1").inspect
  end

  def test_nil_attributes
    assert_equal({}, FreeAgent::Object.new(nil).to_h)
  end
end
