require "test_helper"

class SalesTaxPeriodsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "sales_tax_periods", fixture: "sales_tax_periods/list_all_sales_tax_periods_for_a_company")

    assert_equal FreeAgent::SalesTaxPeriod, client.sales_tax_periods.list.first.class
  end

  def test_retrieve
    stub_api(:get, "sales_tax_periods/2", fixture: "sales_tax_periods/get_a_single_sales_tax_period")

    period = client.sales_tax_periods.retrieve(id: 2)

    assert_equal "First Tax", period.sales_tax_name
    assert_equal "2.0", period.sales_tax_rate_1
  end

  def test_create_sends_the_required_attributes
    attributes = { sales_tax_name: "First Tax", sales_tax_registration_status: "Registered", sales_tax_rate_1: "2.0", sales_tax_is_value_added: true, effective_date: "2016-09-21" }
    stub_api(:post, "sales_tax_periods", request_body: { sales_tax_period: attributes.merge(sales_tax_rate_2: "3.0") },
      status: 201, fixture: "sales_tax_periods/create_a_sales_tax_period")

    period = client.sales_tax_periods.create(**attributes, sales_tax_rate_2: "3.0")

    assert_equal "2016-09-21", period.effective_date
  end

  def test_update_wraps_the_payload
    stub_api(:put, "sales_tax_periods/2", request_body: { sales_tax_period: { sales_tax_rate_1: "2.5" } }, fixture: "sales_tax_periods/get_a_single_sales_tax_period")

    assert_equal FreeAgent::SalesTaxPeriod, client.sales_tax_periods.update(id: 2, sales_tax_rate_1: "2.5").class
  end

  def test_delete
    stub_api(:delete, "sales_tax_periods/2")

    assert_equal true, client.sales_tax_periods.delete(id: 2)
  end
end
