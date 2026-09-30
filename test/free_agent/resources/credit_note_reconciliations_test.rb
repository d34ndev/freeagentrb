require "test_helper"

class CreditNoteReconciliationsResourceTest < Minitest::Test
  CREDIT_NOTE = "https://api.freeagent.com/v2/credit_notes/2".freeze
  INVOICE = "https://api.freeagent.com/v2/invoices/1".freeze

  def test_list
    stub_api(:get, "credit_note_reconciliations", query: { updated_since: "2017-05-22T09:00:00.000Z" },
      fixture: "credit_note_reconciliations/list_all_credit_note_reconciliations")

    reconciliation = client.credit_note_reconciliations.list(updated_since: "2017-05-22T09:00:00.000Z").first

    assert_equal FreeAgent::CreditNoteReconciliation, reconciliation.class
    assert_equal 100.0, reconciliation.gross_value
  end

  def test_retrieve
    stub_api(:get, "credit_note_reconciliations/1", fixture: "credit_note_reconciliations/get_a_single_credit_note_reconciliation")

    assert_equal 100.0, client.credit_note_reconciliations.retrieve(id: 1).gross_value
  end

  def test_create_wraps_the_payload
    stub_api(:post, "credit_note_reconciliations",
      request_body: { credit_note_reconciliation: { credit_note: CREDIT_NOTE, invoice: INVOICE, gross_value: "3.0", dated_on: "2020-08-10" } },
      status: 201, fixture: "credit_note_reconciliations/create_a_credit_note_reconciliation")

    reconciliation = client.credit_note_reconciliations.create(credit_note: CREDIT_NOTE, invoice: INVOICE, gross_value: "3.0", dated_on: "2020-08-10")

    assert_equal 3.0, reconciliation.gross_value
    assert_equal "2", reconciliation.id
  end

  def test_update_wraps_the_payload
    stub_api(:put, "credit_note_reconciliations/2", request_body: { credit_note_reconciliation: { gross_value: "3.0" } },
      fixture: "credit_note_reconciliations/create_a_credit_note_reconciliation")

    assert_equal 3.0, client.credit_note_reconciliations.update(id: 2, gross_value: "3.0").gross_value
  end

  def test_delete
    stub_api(:delete, "credit_note_reconciliations/2")

    assert_equal true, client.credit_note_reconciliations.delete(id: 2)
  end
end
