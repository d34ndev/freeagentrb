require "test_helper"

class ProfitAndLossResourceTest < Minitest::Test
  def test_summary_returns_the_profit_and_loss
    stub_api(:get, "accounting/profit_and_loss/summary", query: { from_date: "2016-06-01", to_date: "2016-09-05" },
      fixture: "profit_and_loss/get_the_p_l_summary")

    summary = client.profit_and_loss.summary(from_date: "2016-06-01", to_date: "2016-09-05")

    assert_equal FreeAgent::ProfitAndLoss, summary.class
    assert_equal 3800.0, summary.income
    assert_equal(-4400.0, summary.operating_profit)
    assert_equal "Dividends", summary.less[1].title
  end

  def test_summary_by_accounting_period
    stub_api(:get, "accounting/profit_and_loss/summary", query: { accounting_period: "2022/23" }, fixture: "profit_and_loss/get_the_p_l_summary")

    assert_equal 11367.0, client.profit_and_loss.summary(accounting_period: "2022/23").retained_profit_carried_forward
  end
end
