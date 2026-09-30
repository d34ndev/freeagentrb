require "test_helper"

class EstimatesResourceTest < Minitest::Test
  CONTACT = "https://api.freeagent.com/v2/contacts/1".freeze

  def test_list
    stub_api(:get, "estimates", query: { view: "recent" }, fixture: "estimates/list_all_estimates")

    estimate = client.estimates.list(view: "recent").first

    assert_equal FreeAgent::Estimate, estimate.class
    assert_equal 25.22, estimate.net_value
  end

  def test_list_with_nested_items
    stub_api(:get, "estimates", query: { nested_estimate_items: "true" }, fixture: "estimates/list_all_estimates_with_nested_estimate_items")

    refute_empty client.estimates.list(nested_estimate_items: true).first.estimate_items
  end

  def test_list_for_contact_project_and_invoice
    project = "https://api.freeagent.com/v2/projects/2"
    invoice = "https://api.freeagent.com/v2/invoices/2"
    stub_api(:get, "estimates", query: { contact: CONTACT }, fixture: "estimates/list_all_estimates")
    stub_api(:get, "estimates", query: { project: project }, fixture: "estimates/list_all_estimates")
    stub_api(:get, "estimates", query: { invoice: invoice }, fixture: "estimates/list_all_estimates")

    assert_equal 1, client.estimates.list_for_contact(contact: CONTACT).count
    assert_equal 1, client.estimates.list_for_project(project: project).count
    assert_equal 1, client.estimates.list_for_invoice(invoice: invoice).count
  end

  def test_retrieve
    stub_api(:get, "estimates/1", fixture: "estimates/get_a_single_estimate")

    estimate = client.estimates.retrieve(id: 1)

    assert_equal "001", estimate.reference
    assert_equal 5.04266, estimate.sales_tax_value
    assert_equal FreeAgent::Object, estimate.estimate_items.first.class
  end

  def test_retrieve_pdf_returns_base64_content
    stub_api(:get, "estimates/1/pdf", body: { pdf: { content: "JVBERi0xLjQK" } })

    assert_equal "JVBERi0xLjQK", client.estimates.retrieve_pdf(id: 1)
  end

  def test_create_wraps_the_payload
    attributes = { contact: CONTACT, dated_on: "2011-09-15", status: "Draft", estimate_type: "Estimate", currency: "GBP", reference: "001" }
    stub_api(:post, "estimates", request_body: { estimate: attributes }, status: 201, fixture: "estimates/create_an_estimate")

    estimate = client.estimates.create(contact: CONTACT, dated_on: "2011-09-15", currency: "GBP", reference: "001")

    assert_equal FreeAgent::Estimate, estimate.class
  end

  def test_duplicate
    stub_api(:post, "estimates/1/duplicate", request_body: {}, fixture: "estimates/get_a_single_estimate")

    assert_equal FreeAgent::Estimate, client.estimates.duplicate(id: 1).class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "estimates/1", request_body: { estimate: { reference: "002" } }, fixture: "estimates/get_a_single_estimate")

    assert_equal FreeAgent::Estimate, client.estimates.update(id: 1, reference: "002").class
  end

  def test_delete
    stub_api(:delete, "estimates/1")

    assert_equal true, client.estimates.delete(id: 1)
  end

  def test_email_nests_the_email_attributes
    stub_api(:post, "estimates/1/send_email", request_body: { estimate: { email: { to: "test@example.com" } } })

    assert_equal true, client.estimates.email(id: 1, to: "test@example.com")
  end

  def test_transitions
    %w[mark_as_sent mark_as_draft mark_as_approved mark_as_rejected convert_to_invoice].each do |transition|
      stub_api(:put, "estimates/1/transitions/#{transition}", request_body: {})

      assert_equal true, client.estimates.public_send(transition, id: 1)
    end
  end

  def test_default_additional_text
    stub_api(:get, "estimates/default_additional_text", fixture: "estimates/default_additional_text")

    assert_equal "Please respond within 21 working days", client.estimates.default_additional_text
  end

  def test_update_default_additional_text
    stub_api(:put, "estimates/default_additional_text", request_body: { default_additional_text: "Respond to this quote within 7 days" },
      fixture: "estimates/default_additional_text_2")

    assert_equal true, client.estimates.update_default_additional_text("Respond to this quote within 7 days")
  end

  def test_delete_default_additional_text
    stub_api(:delete, "estimates/default_additional_text")

    assert_equal true, client.estimates.delete_default_additional_text
  end
end
