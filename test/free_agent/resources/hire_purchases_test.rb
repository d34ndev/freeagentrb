require "test_helper"

class HirePurchasesResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "hire_purchases", fixture: "hire_purchases/list_all_hire_purchases")

    assert_equal FreeAgent::HirePurchase, client.hire_purchases.list.first.class
  end

  def test_retrieve
    stub_api(:get, "hire_purchases/1", fixture: "hire_purchases/get_a_single_hire_purchase")

    hire_purchase = client.hire_purchases.retrieve(id: 1)

    assert_equal "My hire purchase bill", hire_purchase.description
    assert_equal "https://api.freeagent.com/v2/bills/1", hire_purchase.bill
  end
end
