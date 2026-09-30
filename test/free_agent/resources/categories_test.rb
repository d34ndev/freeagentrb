require "test_helper"

class CategoriesResourceTest < Minitest::Test
  def test_list_flattens_every_category_type
    stub_api(:get, "categories", fixture: "categories/list_all_categories")

    categories = client.categories.list

    # Unlike other resources this returns a plain Array, not a Collection
    assert_equal Array, categories.class
    assert_equal FreeAgent::Category, categories.first.class
    assert_equal %w[admin_expenses_categories cost_of_sales_categories income_categories general_categories], categories.map(&:category_type).uniq
  end

  def test_list_preserves_category_attributes
    stub_api(:get, "categories", query: { sub_accounts: "true" }, fixture: "categories/list_all_categories")

    admin = client.categories.list(sub_accounts: true).first

    assert_equal "Accommodation and Meals", admin.description
    assert_equal "285", admin.nominal_code
    assert_equal true, admin.allowable_for_tax
  end

  def test_retrieve_tags_the_category_type
    stub_api(:get, "categories/001", fixture: "categories/get_a_single_category")

    category = client.categories.retrieve(nominal_code: "001")

    assert_equal FreeAgent::Category, category.class
    assert_equal "Sales", category.description
    assert_equal "income_categories", category.category_type
  end

  def test_create_wraps_the_payload
    stub_api(:post, "categories", request_body: { category: { description: "Custom Income Category", nominal_code: "047", category_group: "income" } },
      status: 201, fixture: "categories/create_a_category")

    category = client.categories.create(description: "Custom Income Category", nominal_code: "047", category_group: "income")

    assert_equal "047", category.nominal_code
    assert_equal "income_categories", category.category_type
  end

  def test_update_wraps_the_payload
    stub_api(:put, "categories/047", request_body: { category: { description: "Renamed" } }, fixture: "categories/update_a_category")

    assert_equal "income_categories", client.categories.update(nominal_code: "047", description: "Renamed").category_type
  end

  def test_delete
    stub_api(:delete, "categories/200", fixture: "categories/delete_a_category")

    assert_equal true, client.categories.delete(nominal_code: "200")
  end
end
