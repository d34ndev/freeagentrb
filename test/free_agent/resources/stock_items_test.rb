require "test_helper"

class StockItemsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "stock_items", query: { sort: "created_at" }, fixture: "stock_items/list_all_stock_items")

    assert_equal FreeAgent::StockItem, client.stock_items.list(sort: "created_at").first.class
  end

  def test_retrieve_coerces_opening_values
    stub_api(:get, "stock_items/3", fixture: "stock_items/get_a_single_stock_item")

    item = client.stock_items.retrieve(id: 3)

    assert_equal "Apple", item.description
    assert_equal 10.0, item.opening_quantity
    assert_equal 1.0, item.opening_balance
  end
end
