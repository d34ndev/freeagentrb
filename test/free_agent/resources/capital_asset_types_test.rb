require "test_helper"

class CapitalAssetTypesResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "capital_asset_types", fixture: "capital_asset_types/list_all_capital_assets")

    type = client.capital_asset_types.list.first

    assert_equal FreeAgent::CapitalAssetType, type.class
    assert_equal "Computer Equipment", type.name
    assert_equal true, type.system_default
  end

  def test_retrieve
    stub_api(:get, "capital_asset_types/397", fixture: "capital_asset_types/get_a_single_capital_asset_type")

    assert_equal FreeAgent::CapitalAssetType, client.capital_asset_types.retrieve(id: 397).class
  end

  def test_create_wraps_the_payload
    stub_api(:post, "capital_asset_types", request_body: { capital_asset_type: { name: "Machinery" } },
      status: 201, fixture: "capital_asset_types/create_a_capital_asset_type")

    assert_equal FreeAgent::CapitalAssetType, client.capital_asset_types.create(name: "Machinery").class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "capital_asset_types/397", request_body: { capital_asset_type: { name: "Plant" } },
      fixture: "capital_asset_types/update_a_capital_asset_type")

    assert_equal FreeAgent::CapitalAssetType, client.capital_asset_types.update(id: 397, name: "Plant").class
  end

  def test_delete
    stub_api(:delete, "capital_asset_types/397", fixture: "capital_asset_types/delete_a_capital_asset_type")

    assert_equal true, client.capital_asset_types.delete(id: 397)
  end
end
