require "test_helper"

class CashflowResourceTest < Minitest::Test
  def test_retrieve_returns_the_cashflow
    stub_api(:get, "cashflow", query: { from_date: "2019-07-01", to_date: "2019-09-30" }, fixture: "cashflow/cashflow_summary_for_a_given_date_range")

    cashflow = client.cashflow.retrieve(from_date: "2019-07-01", to_date: "2019-09-30")

    assert_equal FreeAgent::Cashflow, cashflow.class
    assert_equal 12593.21, cashflow.balance
    assert_equal "68869.76", cashflow.incoming.total
    assert_equal 7, cashflow.outgoing.months.first.month
  end
end
