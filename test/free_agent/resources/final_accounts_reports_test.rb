require "test_helper"

class FinalAccountsReportsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "final_accounts_reports", fixture: "final_accounts_reports/list_final_accounts_reports_for_a_company")

    reports = client.final_accounts_reports.list

    assert_equal FreeAgent::FinalAccountsReport, reports.first.class
    assert_equal "pending", reports.first.filing_status
  end

  def test_retrieve
    stub_api(:get, "final_accounts_reports/2022-12-31", fixture: "final_accounts_reports/fetch_details_for_a_final_accounts_report")

    assert_equal FreeAgent::FinalAccountsReport, client.final_accounts_reports.retrieve(period_ends_on: "2022-12-31").class
  end

  def test_transitions
    stub_api(:put, "final_accounts_reports/2022-12-31/mark_as_filed", request_body: {}, fixture: "final_accounts_reports/mark_a_final_accounts_report_as_filed")
    stub_api(:put, "final_accounts_reports/2022-12-31/mark_as_unfiled", request_body: {}, fixture: "final_accounts_reports/mark_a_final_accounts_report_as_unfiled")

    assert_equal true, client.final_accounts_reports.mark_as_filed(period_ends_on: "2022-12-31")
    assert_equal true, client.final_accounts_reports.mark_as_unfiled(period_ends_on: "2022-12-31")
  end
end
