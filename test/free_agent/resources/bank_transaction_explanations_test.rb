require "test_helper"

class BankTransactionExplanationsResourceTest < Minitest::Test
  BANK_ACCOUNT = "https://api.freeagent.com/v2/bank_accounts/1".freeze
  BANK_TRANSACTION = "https://api.freeagent.com/v2/bank_transactions/8".freeze

  def test_list
    stub_api(:get, "bank_transaction_explanations", query: { bank_account: BANK_ACCOUNT, from_date: "2019-01-01" },
      fixture: "bank_transaction_explanations/list_all_bank_transaction_explanations")

    explanations = client.bank_transaction_explanations.list(bank_account: BANK_ACCOUNT, from_date: "2019-01-01")

    assert_equal FreeAgent::Collection, explanations.class
    assert_equal FreeAgent::BankTransactionExplanation, explanations.first.class
    assert_equal "20", explanations.first.id
  end

  def test_retrieve
    stub_api(:get, "bank_transaction_explanations/8", fixture: "bank_transaction_explanations/get_a_single_bank_transaction_explanation")

    explanation = client.bank_transaction_explanations.retrieve(id: 8)

    assert_equal FreeAgent::BankTransactionExplanation, explanation.class
    assert_equal "harness end-to-end e-business", explanation.description
    assert_equal true, explanation.is_deletable
  end

  def test_create_wraps_the_payload
    attributes = { bank_transaction: BANK_TRANSACTION, dated_on: "2019-05-01", gross_value: "-730.0", category: "https://api.freeagent.com/v2/categories/285" }
    stub_api(:post, "bank_transaction_explanations", request_body: { bank_transaction_explanation: attributes },
      status: 201, fixture: "bank_transaction_explanations/create_a_bank_transaction_explanation")

    explanation = client.bank_transaction_explanations.create(**attributes)

    assert_equal FreeAgent::BankTransactionExplanation, explanation.class
    assert_equal "-730.0", explanation.gross_value
  end

  def test_create_requires_a_bank_account_or_transaction
    assert_raises(RuntimeError) { client.bank_transaction_explanations.create(dated_on: "2019-05-01") }
  end

  def test_update_wraps_the_payload
    stub_api(:put, "bank_transaction_explanations/8", request_body: { bank_transaction_explanation: { rebill_type: "price", rebill_factor: "800" } },
      fixture: "bank_transaction_explanations/update_a_bank_transaction_explanation")

    explanation = client.bank_transaction_explanations.update(id: 8, rebill_type: "price", rebill_factor: "800")

    assert_equal "price", explanation.rebill_type
  end

  def test_delete
    stub_api(:delete, "bank_transaction_explanations/8")

    assert_equal true, client.bank_transaction_explanations.delete(id: 8)
  end

  def test_attachments_sends_the_minimum_api_version
    stub_api(:get, "bank_transaction_explanations/8/attachments", headers: { "X-Api-Version" => "2026-09-01" },
      fixture: "bank_transaction_explanation_attachments/list_all_file_attachments_for_a_bank_transaction_explanation")

    attachments = client.bank_transaction_explanations.attachments(id: 8)

    assert_equal FreeAgent::Attachment, attachments.first.class
    assert_equal "3", attachments.first.id
    assert_equal "receipt1.png", attachments.first.file_name
  end

  def test_attachments_keeps_a_newer_client_api_version
    stub_api(:get, "bank_transaction_explanations/8/attachments", headers: { "X-Api-Version" => "2027-01-01" },
      fixture: "bank_transaction_explanation_attachments/delete_all_file_attachments_associated_with_a_bank_transaction_explanation")

    assert_equal 0, client(api_version: "2027-01-01").bank_transaction_explanations.attachments(id: 8).count
  end

  def test_add_attachments
    attachment = { data: "aGVsbG8=", file_name: "receipt3.png", content_type: "image/png", description: "Receipt for ink" }
    stub_api(:post, "bank_transaction_explanations/8/attachments", request_body: { attachments: [ attachment ] }, status: 201,
      fixture: "bank_transaction_explanation_attachments/list_all_file_attachments_for_a_bank_transaction_explanation")

    attachments = client.bank_transaction_explanations.add_attachments(id: 8, attachments: [ attachment ])

    assert_equal FreeAgent::Attachment, attachments.first.class
  end

  def test_update_attachments
    url = "https://api.freeagent.com/v2/attachments/3"
    stub_api(:put, "bank_transaction_explanations/8/attachments", request_body: { attachments: [ { url: url, _destroy: "true" } ] },
      fixture: "bank_transaction_explanation_attachments/delete_all_file_attachments_associated_with_a_bank_transaction_explanation")

    attachments = client.bank_transaction_explanations.update_attachments(id: 8, attachments: [ { url: url, _destroy: "true" } ])

    assert_equal 0, attachments.count
  end

  def test_delete_attachments
    stub_api(:delete, "bank_transaction_explanations/8/attachments",
      fixture: "bank_transaction_explanation_attachments/delete_all_file_attachments_associated_with_a_bank_transaction_explanation")

    assert_equal true, client.bank_transaction_explanations.delete_attachments(id: 8)
  end
end
