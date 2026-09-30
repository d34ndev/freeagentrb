require "test_helper"

class InvoicesResourceTest < Minitest::Test
  CONTACT = "https://api.freeagent.com/v2/contacts/2".freeze

  def test_list
    stub_api(:get, "invoices", query: { view: "recent_open_or_overdue", sort: "-updated_at" }, fixture: "invoices/list_all_invoices")

    invoices = client.invoices.list(view: "recent_open_or_overdue", sort: "-updated_at")

    assert_equal FreeAgent::Collection, invoices.class
    assert_equal FreeAgent::Invoice, invoices.first.class
  end

  def test_list_with_nested_items
    stub_api(:get, "invoices", query: { nested_invoice_items: "true" }, fixture: "invoices/list_all_invoices_with_nested_invoice_items")

    refute_empty client.invoices.list(nested_invoice_items: true).first.invoice_items
  end

  def test_list_for_contact_and_project
    project = "https://api.freeagent.com/v2/projects/2"
    stub_api(:get, "invoices", query: { contact: CONTACT }, fixture: "invoices/list_all_invoices")
    stub_api(:get, "invoices", query: { project: project }, fixture: "invoices/list_all_invoices")

    assert_equal FreeAgent::Invoice, client.invoices.list_for_contact(contact: CONTACT).first.class
    assert_equal FreeAgent::Invoice, client.invoices.list_for_project(project: project).first.class
  end

  def test_retrieve
    stub_api(:get, "invoices/1", fixture: "invoices/get_a_single_invoice")

    invoice = client.invoices.retrieve(id: 1)

    assert_equal FreeAgent::Invoice, invoice.class

    # Nested objects and arrays are exposed too
    assert_equal true, invoice.payment_methods.paypal
    assert_equal "Test InvoiceItem", invoice.invoice_items.first.description
  end

  def test_retrieve_coerces_monetary_values_to_floats
    stub_api(:get, "invoices/1", fixture: "invoices/get_a_single_invoice")

    invoice = client.invoices.retrieve(id: 1)

    assert_equal 200.0, invoice.total_value
    assert_equal 50.0, invoice.paid_value
    assert_equal 150.0, invoice.due_value
    assert_equal 0.0, invoice.net_value

    # Other decimal-ish values are left as strings
    assert_equal "1.0", invoice.exchange_rate
  end

  def test_retrieve_pdf_returns_base64_content
    stub_api(:get, "invoices/1/pdf", body: { pdf: { content: "JVBERi0xLjQK" } })

    assert_equal "JVBERi0xLjQK", client.invoices.retrieve_pdf(id: 1)
  end

  def test_create_wraps_the_payload
    items = [ { item_type: "Hours", quantity: "0.0", price: "0.0", description: "Test InvoiceItem" } ]
    stub_api(:post, "invoices",
      request_body: { invoice: { contact: CONTACT, dated_on: "2011-08-29", payment_terms_in_days: 5, invoice_items: items } },
      status: 201, fixture: "invoices/create_an_invoice")

    invoice = client.invoices.create(contact: CONTACT, dated_on: "2011-08-29", payment_terms_in_days: 5, invoice_items: items)

    assert_equal "Draft", invoice.status
  end

  def test_create_defaults_payment_terms_to_zero
    stub_api(:post, "invoices", request_body: { invoice: { contact: CONTACT, dated_on: "2011-08-29", payment_terms_in_days: 0 } },
      status: 201, fixture: "invoices/create_an_invoice")

    assert_equal FreeAgent::Invoice, client.invoices.create(contact: CONTACT, dated_on: "2011-08-29").class
  end

  def test_duplicate
    stub_api(:post, "invoices/1/duplicate", request_body: {}, fixture: "invoices/create_an_invoice")

    assert_equal FreeAgent::Invoice, client.invoices.duplicate(id: 1).class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "invoices/1", request_body: { invoice: { reference: "004" } }, fixture: "invoices/get_a_single_invoice")

    assert_equal FreeAgent::Invoice, client.invoices.update(id: 1, reference: "004").class
  end

  def test_delete
    stub_api(:delete, "invoices/1")

    assert_equal true, client.invoices.delete(id: 1)
  end

  def test_email_nests_attributes_under_email
    stub_api(:post, "invoices/1/send_email", request_body: { invoice: { email: { to: "someone@example.com", subject: "Your invoice" } } })

    assert_equal true, client.invoices.email(id: 1, to: "someone@example.com", subject: "Your invoice")
  end

  def test_transitions
    %w[mark_as_sent mark_as_scheduled mark_as_draft mark_as_cancelled convert_to_credit_note].each do |transition|
      stub_api(:put, "invoices/1/transitions/#{transition}", request_body: {})

      assert_equal true, client.invoices.public_send(transition, id: 1)
    end
  end

  def test_direct_debit
    stub_api(:post, "invoices/1/direct_debit", request_body: {})

    assert_equal true, client.invoices.direct_debit(id: 1)
  end

  def test_timeline
    stub_api(:get, "invoices/timeline", fixture: "invoices/get_invoice_timeline")

    item = client.invoices.timeline.first

    assert_equal FreeAgent::TimelineItem, item.class
    assert_equal "007", item.reference
    assert_equal 14.4, item.amount
  end

  def test_default_additional_text
    stub_api(:get, "invoices/default_additional_text", fixture: "invoices/default_additional_text")

    assert_equal "Please pay within 21 working days", client.invoices.default_additional_text
  end

  def test_update_default_additional_text
    stub_api(:put, "invoices/default_additional_text", request_body: { default_additional_text: "Pay within 7 days" },
      fixture: "invoices/default_additional_text_2")

    assert_equal true, client.invoices.update_default_additional_text("Pay within 7 days")
  end

  def test_delete_default_additional_text
    stub_api(:delete, "invoices/default_additional_text")

    assert_equal true, client.invoices.delete_default_additional_text
  end
end
