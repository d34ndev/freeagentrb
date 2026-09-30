require "test_helper"

class BankTransactionsResourceTest < Minitest::Test
  BANK_ACCOUNT = "https://api.freeagent.com/v2/bank_accounts/1".freeze

  def test_list
    stub_api(:get, "bank_transactions", query: { bank_account: BANK_ACCOUNT, view: "unexplained" },
      fixture: "bank_transactions/list_all_bank_transactions_under_a_certain_bank_account")

    bank_transactions = client.bank_transactions.list(bank_account: BANK_ACCOUNT, view: "unexplained")

    assert_equal FreeAgent::Collection, bank_transactions.class
    assert_equal FreeAgent::BankTransaction, bank_transactions.first.class
    assert_equal "8", bank_transactions.first.id
    assert_equal(-730.0, bank_transactions.first.amount)
  end

  def test_retrieve
    stub_api(:get, "bank_transactions/15", fixture: "bank_transactions/get_a_single_bank_transaction")

    bank_transaction = client.bank_transactions.retrieve(id: 15)

    assert_equal FreeAgent::BankTransaction, bank_transaction.class
    assert_equal(-730.0, bank_transaction.amount)
    assert_equal 0.0, bank_transaction.unexplained_amount
  end

  def test_create_posts_the_statement
    statement = [ { dated_on: "2026-08-15", description: "Hosting", amount: "-10.0", transaction_type: "DEBIT" } ]
    stub_api(:post, "bank_transactions/statement", query: { bank_account: BANK_ACCOUNT }, request_body: { statement: statement })

    assert_equal true, client.bank_transactions.create(bank_account: BANK_ACCOUNT, statement: statement)
  end

  def test_upload_sends_the_file
    stub_request(:post, "#{API_URL}/bank_transactions/statement")
      .with(query: { bank_account: BANK_ACCOUNT }, headers: { "Content-Type" => %r{\Amultipart/form-data} }) { |request| request.body.include?("Dunder Mifflin") }

    filepath = File.join(FIXTURES_DIR, "example_statement.csv")

    assert_equal true, client.bank_transactions.upload(bank_account: BANK_ACCOUNT, statement: filepath)
  end

  def test_delete
    stub_api(:delete, "bank_transactions/15")

    assert_equal true, client.bank_transactions.delete(id: 15)
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
