require "test_helper"

class CapitalAssetsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "capital_assets", query: { view: "all" }, fixture: "capital_assets/list_all_capital_assets")

    asset = client.capital_assets.list(view: "all").first

    assert_equal FreeAgent::CapitalAsset, asset.class
    assert_equal "Computer", asset.description
    assert_equal "1", asset.id
  end

  def test_retrieve_with_history
    stub_api(:get, "capital_assets/3", query: { include_history: "true" }, fixture: "capital_assets/get_a_single_capital_asset")

    asset = client.capital_assets.retrieve(id: 3, include_history: true)

    assert_equal "Workstation", asset.description
    assert_equal "2015-12-07", asset.disposed_on
  end
end
