require "test_helper"

class CisBandsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "cis_bands", fixture: "cis_bands/list_all_cis_bands_for_a_company")

    bands = client.cis_bands.list

    assert_equal FreeAgent::CisBand, bands.first.class
    assert_equal "cis_gross", bands.first.name
    assert_equal "0.2", bands.data[1].deduction_rate
  end
end
