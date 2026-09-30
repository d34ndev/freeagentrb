require "test_helper"

class SelfAssessmentReturnsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "users/119/self_assessment_returns", fixture: "income_tax_returns/list_income_tax_returns_for_a_user")

    tax_return = client.self_assessment_returns.list(user_id: 119).first

    assert_equal FreeAgent::SelfAssessmentReturn, tax_return.class
    assert_equal "2022-04-05", tax_return.period_ends_on
    assert_equal "Balancing Payment", tax_return.payments.first.label
  end

  def test_retrieve
    stub_api(:get, "users/119/self_assessment_returns/2024-04-05", fixture: "income_tax_returns/fetch_details_for_an_income_tax_return")

    assert_equal FreeAgent::SelfAssessmentReturn, client.self_assessment_returns.retrieve(user_id: 119, period_ends_on: "2024-04-05").class
  end

  def test_filing_transitions
    stub_api(:put, "users/119/self_assessment_returns/2024-04-05/mark_as_filed", request_body: {}, fixture: "income_tax_returns/mark_an_income_tax_return_as_filed")
    stub_api(:put, "users/119/self_assessment_returns/2024-04-05/mark_as_unfiled", request_body: {}, fixture: "income_tax_returns/mark_an_income_tax_return_as_unfiled")

    assert_equal true, client.self_assessment_returns.mark_as_filed(user_id: 119, period_ends_on: "2024-04-05")
    assert_equal true, client.self_assessment_returns.mark_as_unfiled(user_id: 119, period_ends_on: "2024-04-05")
  end

  def test_payment_transitions_are_keyed_by_payment_date
    path = "users/119/self_assessment_returns/2024-04-05/payments/2024-01-31"
    stub_api(:put, "#{path}/mark_as_paid", request_body: {}, fixture: "income_tax_returns/mark_an_income_tax_return_payment_as_paid")
    stub_api(:put, "#{path}/mark_as_unpaid", request_body: {}, fixture: "income_tax_returns/mark_an_income_tax_return_payment_as_unpaid")

    assert_equal true, client.self_assessment_returns.mark_payment_as_paid(user_id: 119, period_ends_on: "2024-04-05", payment_date: "2024-01-31")
    assert_equal true, client.self_assessment_returns.mark_payment_as_unpaid(user_id: 119, period_ends_on: "2024-04-05", payment_date: "2024-01-31")
  end
end
