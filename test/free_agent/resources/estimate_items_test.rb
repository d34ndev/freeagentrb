require "test_helper"

class EstimateItemsResourceTest < Minitest::Test
  ESTIMATE = "https://api.freeagent.com/v2/estimates/1".freeze

  # The estimate URL is a sibling of estimate_item, not nested inside it
  def test_create_sends_estimate_and_item_as_separate_roots
    stub_api(:post, "estimate_items",
      request_body: { estimate: ESTIMATE, estimate_item: { item_type: "Hours", quantity: "1.03333333", price: "12.2", description: "sada" } },
      fixture: "estimates/create_an_estimate_item")

    item = client.estimate_items.create(estimate: ESTIMATE, item_type: "Hours", quantity: "1.03333333", price: "12.2", description: "sada")

    assert_equal FreeAgent::EstimateItem, item.class
    assert_equal "2", item.id
  end

  def test_update_wraps_the_payload
    stub_api(:put, "estimate_items/2", request_body: { estimate_item: { description: "sada" } }, fixture: "estimates/create_an_estimate_item")

    assert_equal "sada", client.estimate_items.update(id: 2, description: "sada").description
  end

  def test_delete
    stub_api(:delete, "estimate_items/2")

    assert_equal true, client.estimate_items.delete(id: 2)
  end
end
