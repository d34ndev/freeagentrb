require "test_helper"

class CorporationTaxReturnsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "corporation_tax_returns", fixture: "corporation_tax_returns/list_corporation_tax_returns_for_a_company")

    tax_return = client.corporation_tax_returns.list.first

    assert_equal FreeAgent::CorporationTaxReturn, tax_return.class
    assert_equal "2022-12-31", tax_return.period_ends_on
    assert_equal 0.0, tax_return.amount_due
  end

  def test_retrieve_is_keyed_by_period_end_date
    stub_api(:get, "corporation_tax_returns/2022-12-31", fixture: "corporation_tax_returns/fetch_details_for_a_corporation_tax_return")

    assert_equal "2022-12-31", client.corporation_tax_returns.retrieve(period_ends_on: "2022-12-31").period_ends_on
  end

  def test_transitions
    {
      mark_as_filed: "mark_a_corporation_tax_return_as_filed",
      mark_as_unfiled: "mark_a_corporation_tax_return_as_unfiled",
      mark_as_paid: "mark_a_corporation_tax_return_as_paid",
      mark_as_unpaid: "mark_a_corporation_tax_return_as_unpaid"
    }.each do |transition, fixture|
      stub_api(:put, "corporation_tax_returns/2022-12-31/#{transition}", request_body: {}, fixture: "corporation_tax_returns/#{fixture}")

      assert_equal true, client.corporation_tax_returns.public_send(transition, period_ends_on: "2022-12-31")
    end
  end
end
