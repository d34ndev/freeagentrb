require "test_helper"

class VatReturnsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "vat_returns", fixture: "vat_returns/list_vat_returns_for_a_company")

    vat_return = client.vat_returns.list.first

    assert_equal FreeAgent::VatReturn, vat_return.class
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, vat_return.period_ends_on)
  end

  def test_retrieve_includes_the_breakdown
    stub_api(:get, "vat_returns/2023-07-31", fixture: "vat_returns/fetch_details_for_a_vat_return")

    vat_return = client.vat_returns.retrieve(period_ends_on: "2023-07-31")

    assert_equal "5450.91", vat_return.payments.first.amount_due
    assert_equal "vatDueSales", vat_return.breakdown.rows.first.key
    assert_equal 1, vat_return.breakdown.rows.first.box_number
  end

  def test_filing_transitions
    stub_api(:put, "vat_returns/2023-07-31/mark_as_filed", request_body: {}, fixture: "vat_returns/mark_a_vat_return_as_filed")
    stub_api(:put, "vat_returns/2023-07-31/mark_as_unfiled", request_body: {}, fixture: "vat_returns/mark_a_vat_return_as_unfiled")

    assert_equal true, client.vat_returns.mark_as_filed(period_ends_on: "2023-07-31")
    assert_equal true, client.vat_returns.mark_as_unfiled(period_ends_on: "2023-07-31")
  end

  def test_payment_transitions_are_keyed_by_payment_date
    stub_api(:put, "vat_returns/2023-07-31/payments/2023-09-07/mark_as_paid", request_body: {}, fixture: "vat_returns/mark_a_vat_return_payment_as_paid")
    stub_api(:put, "vat_returns/2023-07-31/payments/2023-09-07/mark_as_unpaid", request_body: {}, fixture: "vat_returns/mark_a_vat_return_payment_as_unpaid")

    assert_equal true, client.vat_returns.mark_payment_as_paid(period_ends_on: "2023-07-31", payment_date: "2023-09-07")
    assert_equal true, client.vat_returns.mark_payment_as_unpaid(period_ends_on: "2023-07-31", payment_date: "2023-09-07")
  end
end
