module FreeAgent
  class BankTransactionExplanationsResource < Resource
    # The attachments endpoints only exist from this API version onwards
    ATTACHMENTS_API_VERSION = "2026-09-01"

    def list(bank_account:, **params)
      attributes = { bank_account: bank_account }

      response = get_request("bank_transaction_explanations", params: attributes.merge(params))
      Collection.from_response(response, type: BankTransactionExplanation)
    end

    def retrieve(id:)
      response = get_request("bank_transaction_explanations/#{id}")
      BankTransactionExplanation.new(response.body["bank_transaction_explanation"])
    end

    def create(**params)
      raise "bank_account or bank_transaction is required" unless !params[:bank_account].nil? || !params[:bank_transaction].nil?
      response = post_request("bank_transaction_explanations", body: { bank_transaction_explanation: params })
      BankTransactionExplanation.new(response.body["bank_transaction_explanation"])
    end

    def update(id:, **params)
      response = put_request("bank_transaction_explanations/#{id}", body: { bank_transaction_explanation: params })
      BankTransactionExplanation.new(response.body["bank_transaction_explanation"]) if response.success?
    end

    def delete(id:)
      response = delete_request("bank_transaction_explanations/#{id}")
      response.success?
    end

    def attachments(id:)
      response = get_request("bank_transaction_explanations/#{id}/attachments", headers: attachments_headers)
      Collection.from_response(response, type: Attachment)
    end

    # Each attachment is a hash of data (Base64-encoded), file_name,
    # content_type and optionally description. Up to 10 per call, 50 in total.
    # Returns every attachment on the explanation.
    def add_attachments(id:, attachments:)
      response = post_request("bank_transaction_explanations/#{id}/attachments", body: { attachments: attachments }, headers: attachments_headers)
      Collection.from_response(response, type: Attachment)
    end

    # Each attachment is identified by its url. Pass _destroy: true to remove
    # one. Creates, updates and removals can be mixed in one call.
    def update_attachments(id:, attachments:)
      response = put_request("bank_transaction_explanations/#{id}/attachments", body: { attachments: attachments }, headers: attachments_headers)
      Collection.from_response(response, type: Attachment)
    end

    def delete_attachments(id:)
      response = delete_request("bank_transaction_explanations/#{id}/attachments", headers: attachments_headers)
      response.success?
    end

    private

    # Keep the client's version if it's newer than the minimum
    def attachments_headers
      { "X-Api-Version" => [ client.api_version, ATTACHMENTS_API_VERSION ].compact.max }
    end
  end
end
