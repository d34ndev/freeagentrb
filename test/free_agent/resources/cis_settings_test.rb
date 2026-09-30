require "test_helper"

class CisSettingsResourceTest < Minitest::Test
  def test_retrieve
    stub_api(:get, "cis_settings", fixture: "cis_settings/get_cis_settings")

    settings = client.cis_settings.retrieve

    assert_equal FreeAgent::CisSettings, settings.class
    assert_equal "Monthly", settings.contractor_details.paye_ni_period
    assert_equal %w[cis_gross cis_standard cis_higher], settings.subcontractor_details.cis_deduction_rates
  end

  def test_update_wraps_the_payload
    stub_api(:put, "cis_settings", request_body: { cis_settings: { contractor_details: nil } }, fixture: "cis_settings/get_cis_settings")

    assert_equal FreeAgent::CisSettings, client.cis_settings.update(contractor_details: nil).class
  end

  def test_update_raises_on_invalid_settings
    stub_api(:put, "cis_settings", status: 422, fixture: "cis_settings/errors")

    error = assert_raises(FreeAgent::Errors::UnprocessableContent) do
      client.cis_settings.update(contractor_details: { paye_ni_period: "Weekly" })
    end
    assert_includes error.message, "must be one of Monthly, Quarterly"
  end
end
