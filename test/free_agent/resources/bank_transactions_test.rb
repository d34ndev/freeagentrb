require "test_helper"

class BankTransactionsResourceTest < Minitest::Test
  def test_bank_transactions_list
    setup_client
    bank_transactions = @client.bank_transactions.list(bank_account: 40462)

    assert_equal FreeAgent::Collection, bank_transactions.class
    assert_equal FreeAgent::BankTransaction, bank_transactions.first.class
  end

  def test_bank_transactions_retrieve
    setup_client
    bank_transaction = @client.bank_transactions.retrieve(id: 2615513)
    assert_equal FreeAgent::BankTransaction, bank_transaction.class
    assert_equal 25.0, bank_transaction.amount
  end

  def test_bank_transactions_create
    setup_client
    statement = [
      {
        "dated_on" => "2025-10-02",
        "description" => "Test Transaction",
        "amount" => 10.0,
        "transaction_type" => "Credit",
        "reference" => "TestRef123"
      }
    ]
    result = @client.bank_transactions.create(bank_account: 40462, statement: statement)
    assert_equal true, result
  end

  def test_bank_transactions_upload
    setup_client
    filepath = File.join(File.dirname(__FILE__), "..", "..", "fixtures", "example_statement.csv")
    result = @client.bank_transactions.upload(bank_account: 40462, statement: filepath)

    assert_equal true, result
  end

  def test_amounts_are_coerced_to_floats
    transaction = FreeAgent::BankTransaction.new(
      "amount" => "-25.50",
      "unexplained_amount" => "0.0",
      "bank_transaction_explanations" => [
        { "url" => "https://api.freeagent.com/v2/bank_transaction_explanations/12345", "gross_value" => "-25.50" }
      ]
    )

    assert_equal(-25.5, transaction.amount)
    assert_equal 0.0, transaction.unexplained_amount
    assert_equal "12345", transaction.bank_transaction_explanations.first.id
    assert_equal(-25.5, transaction.bank_transaction_explanations.first.gross_value)
  end
end
