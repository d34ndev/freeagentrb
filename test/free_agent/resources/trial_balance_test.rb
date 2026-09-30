require "test_helper"

class TrialBalanceResourceTest < Minitest::Test
  def test_summary_returns_items
    stub_api(:get, "accounting/trial_balance/summary", query: { to_date: "2014-05-01" }, fixture: "trial_balance/get_the_trial_balance_summary")

    items = client.trial_balance.summary(to_date: "2014-05-01")

    assert_equal FreeAgent::TrialBalanceItem, items.first.class
    assert_equal "Cost of Sales", items.first.name
    assert_equal 275.0, items.first.total
  end

  def test_opening_balances
    stub_api(:get, "accounting/trial_balance/summary/opening_balances", fixture: "trial_balance/get_the_opening_balances")

    items = client.trial_balance.opening_balances

    assert_equal "Sales", items.first.name
    assert_equal 250.0, items.first.total
  end
end
