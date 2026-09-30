require "test_helper"

class PayrollResourceTest < Minitest::Test
  def test_list_returns_the_periods
    stub_api(:get, "payroll/2026", fixture: "payroll/list_all_periods_for_a_given_tax_year")

    period = client.payroll.list(year: 2026).first

    assert_equal FreeAgent::PayrollPeriod, period.class
    assert_equal "Monthly", period.frequency
  end

  def test_payments
    stub_api(:get, "payroll/2026", fixture: "payroll/list_all_periods_for_a_given_tax_year")

    payment = client.payroll.payments(year: 2026).first

    assert_equal "2025-05-22", payment.due_on
    assert_equal "unpaid", payment.status
  end

  def test_retrieve_includes_payslips
    stub_api(:get, "payroll/2026/0", fixture: "payroll/list_all_payslips_for_a_given_period")

    period = client.payroll.retrieve(year: 2026, period: 0)

    assert_equal FreeAgent::PayrollPeriod, period.class
    assert_equal "1100L", period.payslips.first.tax_code
  end

  def test_payment_transitions_are_keyed_by_payment_date
    stub_api(:put, "payroll/2026/payments/2025-05-22/mark_as_paid", request_body: {}, fixture: "payroll/mark_a_payment_as_paid")
    stub_api(:put, "payroll/2026/payments/2025-05-22/mark_as_unpaid", request_body: {}, fixture: "payroll/mark_a_payment_as_unpaid")

    assert_equal true, client.payroll.mark_payment_as_paid(year: 2026, payment_date: "2025-05-22")
    assert_equal true, client.payroll.mark_payment_as_unpaid(year: 2026, payment_date: "2025-05-22")
  end
end
