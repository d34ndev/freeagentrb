require "test_helper"

class BankTransactionExplanationsResourceTest < Minitest::Test
  def test_bank_transaction_explanations_list
    setup_client
    bank_transaction_explanations = @client.bank_transaction_explanations.list(bank_account: 40462)

    assert_equal FreeAgent::Collection, bank_transaction_explanations.class
    assert_equal FreeAgent::BankTransactionExplanation, bank_transaction_explanations.first.class
  end

  def test_bank_transaction_explanations_retrieve
    setup_client
    bank_transaction_explanation = @client.bank_transaction_explanations.retrieve(id: 1775286)
    assert_equal FreeAgent::BankTransactionExplanation, bank_transaction_explanation.class
    assert_equal "Sales", bank_transaction_explanation.type
  end

  def test_bank_transaction_explanations_create
    setup_client
    bank_transaction_explanation = @client.bank_transaction_explanations.create(
      bank_account: 40462,
      bank_transaction: 2615522,
      type: "Payment",
      category: 268,
      dated_on: "2025-10-02",
      gross_value: 6.07,
      description: "AWS Hosting",
    )

    assert_equal FreeAgent::BankTransactionExplanation, bank_transaction_explanation.class
    assert_equal "AWS Hosting", bank_transaction_explanation.description
  end

  def test_bank_transaction_explanations_delete
    setup_client
    result = @client.bank_transaction_explanations.delete(id: 1775294)

    assert_equal true, result
  end

  def test_update_wraps_the_payload
    body = nil
    client = stub_client do |stubs|
      stubs.put("/v2/bank_transaction_explanations/123") do |env|
        body = JSON.parse(env.body)
        json({ "bank_transaction_explanation" => { "description" => "Hosting" } })
      end
    end

    explanation = client.bank_transaction_explanations.update(id: 123, description: "Hosting")

    assert_equal "Hosting", explanation.description
    assert_equal({ "bank_transaction_explanation" => { "description" => "Hosting" } }, body)
  end

  def test_attachments_sends_the_minimum_api_version
    version = nil
    client = stub_client do |stubs|
      stubs.get("/v2/bank_transaction_explanations/123/attachments") do |env|
        version = env.request_headers["X-Api-Version"]
        json({ "attachments" => [ { "url" => "https://api.freeagent.com/v2/attachments/33", "file_name" => "receipt.png" } ] })
      end
    end

    attachments = client.bank_transaction_explanations.attachments(id: 123)

    assert_equal "2026-09-01", version
    assert_equal FreeAgent::Attachment, attachments.first.class
    assert_equal "33", attachments.first.id
  end

  def test_attachments_keeps_a_newer_client_api_version
    version = nil
    client = stub_client(api_version: "2027-01-01") do |stubs|
      stubs.get("/v2/bank_transaction_explanations/123/attachments") do |env|
        version = env.request_headers["X-Api-Version"]
        json({ "attachments" => [] })
      end
    end

    client.bank_transaction_explanations.attachments(id: 123)

    assert_equal "2027-01-01", version
  end

  def test_add_attachments_posts_the_attachments
    body = nil
    client = stub_client do |stubs|
      stubs.post("/v2/bank_transaction_explanations/123/attachments") do |env|
        body = JSON.parse(env.body)
        json({ "attachments" => [ { "file_name" => "receipt.png" } ] }, status: 201)
      end
    end

    attachment = { data: "aGVsbG8=", file_name: "receipt.png", content_type: "image/png" }
    attachments = client.bank_transaction_explanations.add_attachments(id: 123, attachments: [ attachment ])

    assert_equal 1, attachments.count
    assert_equal({ "attachments" => [ { "data" => "aGVsbG8=", "file_name" => "receipt.png", "content_type" => "image/png" } ] }, body)
  end

  def test_update_attachments_puts_the_attachments
    body = nil
    client = stub_client do |stubs|
      stubs.put("/v2/bank_transaction_explanations/123/attachments") do |env|
        body = JSON.parse(env.body)
        json({ "attachments" => [] })
      end
    end

    url = "https://api.freeagent.com/v2/attachments/33"
    client.bank_transaction_explanations.update_attachments(id: 123, attachments: [ { url: url, _destroy: true } ])

    assert_equal({ "attachments" => [ { "url" => url, "_destroy" => true } ] }, body)
  end

  def test_delete_attachments_returns_true
    client = stub_client do |stubs|
      stubs.delete("/v2/bank_transaction_explanations/123/attachments") { json({ "attachments" => [] }) }
    end

    assert_equal true, client.bank_transaction_explanations.delete_attachments(id: 123)
  end
end
