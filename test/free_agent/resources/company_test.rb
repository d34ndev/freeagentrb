require "test_helper"

class CompanyResourceTest < Minitest::Test
  def test_retrieve
    stub_api(:get, "company", fixture: "company/general_company_information")

    company = client.company.retrieve

    assert_equal FreeAgent::Company, company.class
    assert_equal "My Company", company.name
    assert_equal "UkLimitedCompany", company.type
    assert_equal "12345", company.id
  end

  def test_business_categories
    stub_api(:get, "company/business_categories", fixture: "company/list_all_business_categories")

    assert_equal "Accounting & Bookkeeping", client.company.business_categories.first
  end

  def test_tax_timeline
    stub_api(:get, "company/tax_timeline", fixture: "company/information_about_upcoming_tax_events")

    item = client.company.tax_timeline.first

    assert_equal FreeAgent::TaxTimelineItem, item.class
    assert_equal "VAT Return 09 11", item.description
    assert_equal(-214.16, item.amount_due)
  end
end
