require "test_helper"

class RecurringInvoicesResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "recurring_invoices", query: { view: "draft" }, fixture: "recurring_invoices/list_all_recurring_invoices")

    assert_equal FreeAgent::RecurringInvoice, client.recurring_invoices.list(view: "draft").first.class
  end

  def test_list_for_contact_and_project
    contact = "https://api.freeagent.com/v2/contacts/1"
    project = "https://api.freeagent.com/v2/projects/1"
    stub_api(:get, "recurring_invoices", query: { contact: contact }, fixture: "recurring_invoices/list_all_recurring_invoices")
    stub_api(:get, "recurring_invoices", query: { project: project }, fixture: "recurring_invoices/list_all_recurring_invoices")

    assert_equal FreeAgent::RecurringInvoice, client.recurring_invoices.list_for_contact(contact: contact).first.class
    assert_equal FreeAgent::RecurringInvoice, client.recurring_invoices.list_for_project(project: project).first.class
  end

  def test_retrieve_coerces_monetary_values
    stub_api(:get, "recurring_invoices/1", fixture: "recurring_invoices/get_a_single_recurring_invoice")

    invoice = client.recurring_invoices.retrieve(id: 1)

    assert_equal "Weekly", invoice.frequency
    assert_equal 2.4, invoice.total_value
    assert_equal 0.4, invoice.sales_tax_value
  end
end
