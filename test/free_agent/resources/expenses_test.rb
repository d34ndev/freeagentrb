require "test_helper"

class ExpensesResourceTest < Minitest::Test
  USER = "https://api.freeagent.com/v2/users/1".freeze

  def test_list
    stub_api(:get, "expenses", query: { view: "recent" }, fixture: "expenses/list_all_expenses")

    expense = client.expenses.list(view: "recent").first

    assert_equal FreeAgent::Expense, expense.class
    assert_equal(-20.0, expense.gross_value)
    assert_equal(-12.0, expense.native_gross_value)
  end

  def test_list_for_user_and_project
    project = "https://api.freeagent.com/v2/projects/2"
    stub_api(:get, "expenses", query: { user: USER }, fixture: "expenses/list_all_expenses")
    stub_api(:get, "expenses", query: { project: project }, fixture: "expenses/list_all_expenses")

    assert_equal 1, client.expenses.list_for_user(user: USER).count
    assert_equal 1, client.expenses.list_for_project(project: project).count
  end

  def test_retrieve
    stub_api(:get, "expenses/1", fixture: "expenses/get_a_single_expense")

    expense = client.expenses.retrieve(id: 1)

    assert_equal FreeAgent::Expense, expense.class
    assert_equal "USD", expense.currency
  end

  def test_create_wraps_the_payload
    category = "https://api.freeagent.com/v2/categories/285"
    stub_api(:post, "expenses",
      request_body: { expense: { user: USER, category: category, dated_on: "2011-08-24", gross_value: "-20.0", description: "Some description" } },
      status: 201, fixture: "expenses/create_an_expense")

    expense = client.expenses.create(user: USER, category: category, dated_on: "2011-08-24", gross_value: "-20.0", description: "Some description")

    assert_equal FreeAgent::Expense, expense.class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "expenses/1", request_body: { expense: { description: "Train fare" } }, fixture: "expenses/get_a_single_expense")

    assert_equal FreeAgent::Expense, client.expenses.update(id: 1, description: "Train fare").class
  end

  def test_delete
    stub_api(:delete, "expenses/1")

    assert_equal true, client.expenses.delete(id: 1)
  end

  def test_mileage_settings
    stub_api(:get, "expenses/mileage_settings", fixture: "expenses/get_mileage_settings")

    settings = client.expenses.mileage_settings

    assert_equal "1970-01-01", settings.engine_type_and_size_options.first.from
    assert_equal [ "Up to 1400cc", "1401-2000cc", "Over 2000cc" ], settings.engine_type_and_size_options.first.value.Petrol
  end
end
