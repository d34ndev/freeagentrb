require "test_helper"

class CisSettingsResourceTest < Minitest::Test
  def test_retrieve_returns_the_settings
    client = stub_client do |stubs|
      stubs.get("/v2/cis_settings") do
        json({ "cis_settings" => { "contractor_details" => { "reporting_starts_on" => "2024-05-06", "paye_ni_period" => "Monthly" } } })
      end
    end

    settings = client.cis_settings.retrieve

    assert_equal FreeAgent::CisSettings, settings.class
    assert_equal "Monthly", settings.contractor_details.paye_ni_period
  end

  def test_update_wraps_the_payload
    body = nil
    client = stub_client do |stubs|
      stubs.put("/v2/cis_settings") do |env|
        body = JSON.parse(env.body)
        json({ "cis_settings" => { "contractor_details" => nil } })
      end
    end

    settings = client.cis_settings.update(contractor_details: nil)

    assert_nil settings.contractor_details
    assert_equal({ "cis_settings" => { "contractor_details" => nil } }, body)
  end
end
