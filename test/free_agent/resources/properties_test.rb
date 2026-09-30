require "test_helper"

class PropertiesResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "properties", fixture: "properties/list_all_properties")

    assert_equal FreeAgent::Property, client.properties.list.first.class
  end

  def test_retrieve
    stub_api(:get, "properties/3", fixture: "properties/get_a_single_property")

    property = client.properties.retrieve(id: 3)

    assert_equal "Wayne Manor", property.name
    assert_equal "3", property.id
  end

  def test_create_wraps_the_payload
    stub_api(:post, "properties", request_body: { property: { address1: "Wayne Manor", postcode: "12345" } },
      status: 201, fixture: "properties/create_a_property")

    assert_equal FreeAgent::Property, client.properties.create(address1: "Wayne Manor", postcode: "12345").class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "properties/3", request_body: { property: { postcode: "54321" } }, fixture: "properties/update_a_property")

    assert_equal FreeAgent::Property, client.properties.update(id: 3, postcode: "54321").class
  end

  def test_delete
    stub_api(:delete, "properties/3")

    assert_equal true, client.properties.delete(id: 3)
  end
end
