require "test_helper"

class TransactionsResourceTest < Minitest::Test
  def test_list_uses_the_accounting_path
    stub_api(:get, "accounting/transactions", query: { from_date: "2023-01-01", to_date: "2023-06-30", nominal_code: "750-1" },
      fixture: "transactions/list_all_transactions")

    transaction = client.transactions.list(from_date: "2023-01-01", to_date: "2023-06-30", nominal_code: "750-1").first

    assert_equal FreeAgent::Transaction, transaction.class
  end

  def test_retrieve
    stub_api(:get, "accounting/transactions/1", fixture: "transactions/get_a_single_transaction")

    transaction = client.transactions.retrieve(id: 1)

    assert_equal "Bank Account", transaction.category_name
    assert_equal 30.0, transaction.debit_value
    assert_equal "1", transaction.id
  end
end
