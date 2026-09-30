module FreeAgent
  class CreditNotesResource < Resource
    def list(**params)
      response = get_request("credit_notes", params: params)
      Collection.from_response(response, type: CreditNote)
    end

    def list_for_contact(contact:, **params)
      response = get_request("credit_notes?contact=#{contact}", params: params)
      Collection.from_response(response, type: CreditNote)
    end

    def list_for_project(project:, **params)
      response = get_request("credit_notes?project=#{project}", params: params)
      Collection.from_response(response, type: CreditNote)
    end

    def retrieve(id:)
      response = get_request("credit_notes/#{id}")
      CreditNote.new(response.body["credit_note"])
    end

    # Returns a Base64-encoded PDF
    def retrieve_pdf(id:)
      response = get_request("credit_notes/#{id}/pdf")
      response.body["pdf"]["content"] if response.success?
    end

    def create(contact:, dated_on:, payment_terms_in_days: 0, **params)
      attributes = { contact: contact, dated_on: dated_on, payment_terms_in_days: payment_terms_in_days }

      response = post_request("credit_notes", body: { credit_note: attributes.merge(params) })
      CreditNote.new(response.body["credit_note"]) if response.success?
    end

    def update(id:, **params)
      response = put_request("credit_notes/#{id}", body: { credit_note: params })
      CreditNote.new(response.body["credit_note"]) if response.success?
    end

    def delete(id:)
      response = delete_request("credit_notes/#{id}")
      response.success?
    end

    def email(id:, to:, **params)
      attributes = { to: to }
      response = post_request("credit_notes/#{id}/send_email", body: { credit_note: { email: attributes.merge(params) } })
      response.success?
    end

    def mark_as_sent(id:)
      response = put_request("credit_notes/#{id}/transitions/mark_as_sent", body: {})
      response.success?
    end

    def mark_as_draft(id:)
      response = put_request("credit_notes/#{id}/transitions/mark_as_draft", body: {})
      response.success?
    end
  end
end
