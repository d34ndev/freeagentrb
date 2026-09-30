require "test_helper"

class CreditNotesResourceTest < Minitest::Test
  CREDIT_NOTE = {
    "url" => "https://api.freeagent.com/v2/credit_notes/1",
    "contact" => "https://api.freeagent.com/v2/contacts/2",
    "dated_on" => "2011-08-29",
    "due_on" => "2011-09-28",
    "reference" => "001",
    "currency" => "GBP",
    "total_value" => "-200.0",
    "status" => "Open",
    "payment_terms_in_days" => 30
  }.freeze

  def test_list
    client = stub_client do |stubs|
      stubs.get("/v2/credit_notes") { json({ "credit_notes" => [ CREDIT_NOTE ] }) }
    end

    credit_notes = client.credit_notes.list

    assert_equal FreeAgent::Collection, credit_notes.class
    assert_equal FreeAgent::CreditNote, credit_notes.first.class
    assert_equal(-200.0, credit_notes.first.total_value)
  end

  def test_retrieve
    client = stub_client do |stubs|
      stubs.get("/v2/credit_notes/1") { json({ "credit_note" => CREDIT_NOTE }) }
    end

    assert_equal "001", client.credit_notes.retrieve(id: 1).reference
  end

  def test_retrieve_pdf_returns_base64_content
    client = stub_client do |stubs|
      stubs.get("/v2/credit_notes/1/pdf") { json({ "pdf" => { "content" => "JVBERi0xLjQK" } }) }
    end

    assert_equal "JVBERi0xLjQK", client.credit_notes.retrieve_pdf(id: 1)
  end

  def test_create_wraps_payload_in_credit_note_root
    body = nil
    client = stub_client do |stubs|
      stubs.post("/v2/credit_notes") do |env|
        body = JSON.parse(env.body)
        json({ "credit_note" => CREDIT_NOTE }, status: 201)
      end
    end

    client.credit_notes.create(contact: "https://api.freeagent.com/v2/contacts/2", dated_on: "2011-08-29")

    assert_equal "https://api.freeagent.com/v2/contacts/2", body["credit_note"]["contact"]
    assert_equal 0, body["credit_note"]["payment_terms_in_days"]
  end

  def test_update_wraps_payload_in_credit_note_root
    body = nil
    client = stub_client do |stubs|
      stubs.put("/v2/credit_notes/1") do |env|
        body = JSON.parse(env.body)
        json({ "credit_note" => CREDIT_NOTE })
      end
    end

    client.credit_notes.update(id: 1, reference: "002")

    assert_equal({ "credit_note" => { "reference" => "002" } }, body)
  end

  def test_delete
    client = stub_client do |stubs|
      stubs.delete("/v2/credit_notes/1") { json({}) }
    end

    assert_equal true, client.credit_notes.delete(id: 1)
  end

  def test_transitions_use_correct_paths
    %w[mark_as_sent mark_as_draft].each do |transition|
      client = stub_client do |stubs|
        stubs.put("/v2/credit_notes/1/transitions/#{transition}") { json({}) }
      end

      assert_equal true, client.credit_notes.public_send(transition, id: 1), "#{transition} requested the wrong path"
      @stubs.verify_stubbed_calls
      @stubs = nil
    end
  end
end
