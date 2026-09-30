require "test_helper"

class BalanceSheetResourceTest < Minitest::Test
  def test_retrieve_returns_the_balance_sheet
    stub_api(:get, "accounting/balance_sheet", query: { as_at_date: "2023-09-30" }, fixture: "balance_sheet/get_the_balance_sheet")

    balance_sheet = client.balance_sheet.retrieve(as_at_date: "2023-09-30")

    assert_equal FreeAgent::BalanceSheet, balance_sheet.class
    assert_equal "2023-09-30", balance_sheet.as_at_date
    assert_equal 11905, balance_sheet.total_assets
    assert_equal "Other Capital Asset Brought Forward", balance_sheet.capital_assets.accounts.first.name
  end

  def test_opening_balances
    stub_api(:get, "accounting/balance_sheet/opening_balances", fixture: "balance_sheet/get_the_opening_balances")

    balance_sheet = client.balance_sheet.opening_balances

    assert_equal FreeAgent::BalanceSheet, balance_sheet.class
    assert_equal 100, balance_sheet.current_assets.accounts.first.total_debit_value
  end
end
