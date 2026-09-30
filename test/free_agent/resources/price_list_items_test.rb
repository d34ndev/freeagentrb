require "test_helper"

class PriceListItemsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "price_list_items", query: { sort: "-created_at" }, body: { price_list_items: [ JSON.parse(read_fixture("price_list_items/get_a_single_price_list_item"))["price_list_item"] ] })

    item = client.price_list_items.list(sort: "-created_at").first

    assert_equal FreeAgent::PriceListItem, item.class
    assert_equal 10.99, item.price
  end

  def test_retrieve
    stub_api(:get, "price_list_items/1", fixture: "price_list_items/get_a_single_price_list_item")

    item = client.price_list_items.retrieve(id: 1)

    assert_equal "A001", item.code
    assert_equal "1", item.id
  end

  def test_create_wraps_the_payload
    stub_api(:post, "price_list_items",
      request_body: { price_list_item: { code: "A001", quantity: "1.0", item_type: "Products", description: "Apple", price: "10.99", vat_status: "standard" } },
      status: 201, fixture: "price_list_items/create_a_price_list_item")

    item = client.price_list_items.create(code: "A001", quantity: "1.0", item_type: "Products", description: "Apple", price: "10.99", vat_status: "standard")

    assert_equal FreeAgent::PriceListItem, item.class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "price_list_items/1", request_body: { price_list_item: { price: "11.99" } }, fixture: "price_list_items/get_a_single_price_list_item")

    assert_equal FreeAgent::PriceListItem, client.price_list_items.update(id: 1, price: "11.99").class
  end

  def test_delete
    stub_api(:delete, "price_list_items/1")

    assert_equal true, client.price_list_items.delete(id: 1)
  end
end
