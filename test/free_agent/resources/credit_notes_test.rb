require "test_helper"

class CreditNotesResourceTest < Minitest::Test
  CONTACT = "https://api.freeagent.com/v2/contacts/2".freeze

  def test_list
    stub_api(:get, "credit_notes", query: { view: "recent_open_or_overdue" }, fixture: "credit_notes/list_all_credit_notes")

    credit_notes = client.credit_notes.list(view: "recent_open_or_overdue")

    assert_equal FreeAgent::Collection, credit_notes.class
    assert_equal FreeAgent::CreditNote, credit_notes.first.class
  end

  def test_list_with_nested_items
    stub_api(:get, "credit_notes", query: { nested_credit_note_items: "true" }, fixture: "credit_notes/list_all_credit_notes_with_nested_credit_note_items")

    refute_empty client.credit_notes.list(nested_credit_note_items: true).first.credit_note_items
  end

  def test_list_for_contact
    stub_api(:get, "credit_notes", query: { contact: CONTACT }, fixture: "credit_notes/list_all_credit_notes")

    assert_equal FreeAgent::CreditNote, client.credit_notes.list_for_contact(contact: CONTACT).first.class
  end

  def test_list_for_project
    project = "https://api.freeagent.com/v2/projects/2"
    stub_api(:get, "credit_notes", query: { project: project }, fixture: "credit_notes/list_all_credit_notes")

    assert_equal FreeAgent::CreditNote, client.credit_notes.list_for_project(project: project).first.class
  end

  def test_retrieve_coerces_monetary_values
    stub_api(:get, "credit_notes/1", fixture: "credit_notes/get_a_single_credit_note")

    credit_note = client.credit_notes.retrieve(id: 1)

    assert_equal "001", credit_note.reference
    assert_equal(-120.0, credit_note.total_value)
    assert_equal 0.0, credit_note.refunded_value
    assert_equal "1.0", credit_note.exchange_rate
  end

  def test_retrieve_pdf_returns_base64_content
    stub_api(:get, "credit_notes/1/pdf", body: { pdf: { content: "JVBERi0xLjQK" } })

    assert_equal "JVBERi0xLjQK", client.credit_notes.retrieve_pdf(id: 1)
  end

  def test_create_wraps_the_payload
    stub_api(:post, "credit_notes", request_body: { credit_note: { contact: CONTACT, dated_on: "2020-01-01", payment_terms_in_days: 0 } },
      status: 201, fixture: "credit_notes/create_a_credit_note")

    assert_equal FreeAgent::CreditNote, client.credit_notes.create(contact: CONTACT, dated_on: "2020-01-01").class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "credit_notes/1", request_body: { credit_note: { reference: "002" } }, fixture: "credit_notes/get_a_single_credit_note")

    assert_equal FreeAgent::CreditNote, client.credit_notes.update(id: 1, reference: "002").class
  end

  def test_delete
    stub_api(:delete, "credit_notes/1")

    assert_equal true, client.credit_notes.delete(id: 1)
  end

  def test_email_nests_the_email_attributes
    stub_api(:post, "credit_notes/1/send_email", request_body: { credit_note: { email: { to: "test@example.com", subject: "Your credit note" } } })

    assert_equal true, client.credit_notes.email(id: 1, to: "test@example.com", subject: "Your credit note")
  end

  def test_transitions
    %w[mark_as_sent mark_as_draft].each do |transition|
      stub_api(:put, "credit_notes/1/transitions/#{transition}", request_body: {})

      assert_equal true, client.credit_notes.public_send(transition, id: 1)
    end
  end
end
