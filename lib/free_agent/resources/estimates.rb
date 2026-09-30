module FreeAgent
  class EstimatesResource < Resource
    def list(**params)
      response = get_request("estimates", params: params)
      Collection.from_response(response, type: Estimate)
    end

    def list_for_contact(contact:, **params)
      response = get_request("estimates?contact=#{contact}", params: params)
      Collection.from_response(response, type: Estimate)
    end

    def list_for_project(project:, **params)
      response = get_request("estimates?project=#{project}", params: params)
      Collection.from_response(response, type: Estimate)
    end

    def list_for_invoice(invoice:, **params)
      response = get_request("estimates?invoice=#{invoice}", params: params)
      Collection.from_response(response, type: Estimate)
    end

    def retrieve(id:)
      response = get_request("estimates/#{id}")
      Estimate.new(response.body["estimate"])
    end

    # Returns a Base64-encoded PDF
    def retrieve_pdf(id:)
      response = get_request("estimates/#{id}/pdf")
      response.body["pdf"]["content"] if response.success?
    end

    def create(contact:, dated_on:, currency:, reference:, status: "Draft", estimate_type: "Estimate", **params)
      attributes = { contact: contact, dated_on: dated_on, status: status, estimate_type: estimate_type, currency: currency, reference: reference }

      response = post_request("estimates", body: { estimate: attributes.merge(params) })
      Estimate.new(response.body["estimate"]) if response.success?
    end

    # The copy is a draft dated today, with the next reference in the sequence
    def duplicate(id:)
      response = post_request("estimates/#{id}/duplicate", body: {})
      Estimate.new(response.body["estimate"]) if response.success?
    end

    def update(id:, **params)
      response = put_request("estimates/#{id}", body: { estimate: params })
      Estimate.new(response.body["estimate"]) if response.success?
    end

    def delete(id:)
      response = delete_request("estimates/#{id}")
      response.success?
    end

    def email(id:, to:, **params)
      attributes = { to: to }
      response = post_request("estimates/#{id}/send_email", body: { estimate: { email: attributes.merge(params) } })
      response.success?
    end

    def mark_as_sent(id:)
      response = put_request("estimates/#{id}/transitions/mark_as_sent", body: {})
      response.success?
    end

    def mark_as_draft(id:)
      response = put_request("estimates/#{id}/transitions/mark_as_draft", body: {})
      response.success?
    end

    def mark_as_approved(id:)
      response = put_request("estimates/#{id}/transitions/mark_as_approved", body: {})
      response.success?
    end

    def mark_as_rejected(id:)
      response = put_request("estimates/#{id}/transitions/mark_as_rejected", body: {})
      response.success?
    end

    def convert_to_invoice(id:)
      response = put_request("estimates/#{id}/transitions/convert_to_invoice", body: {})
      response.success?
    end

    # The text added to the bottom of every new estimate
    def default_additional_text
      response = get_request("estimates/default_additional_text")
      response.body["default_additional_text"]
    end

    def update_default_additional_text(text)
      response = put_request("estimates/default_additional_text", body: { default_additional_text: text })
      response.success?
    end

    def delete_default_additional_text
      response = delete_request("estimates/default_additional_text")
      response.success?
    end
  end
end
