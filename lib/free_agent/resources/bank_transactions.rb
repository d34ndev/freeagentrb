module FreeAgent
  class BankTransactionsResource < Resource
    def list(bank_account:, **params)
      attributes = { bank_account: bank_account }

      response = get_request("bank_transactions", params: attributes.merge(params))
      Collection.from_response(response, type: BankTransaction)
    end

    def retrieve(id:)
      response = get_request("bank_transactions/#{id}")
      BankTransaction.new(response.body["bank_transaction"])
    end

    # Statement should be an array of transactions
    def create(bank_account:, statement:)
      response = post_request("bank_transactions/statement?bank_account=#{bank_account}", body: { statement: statement })
      response.success?
    end

    def upload(bank_account:, statement:)
      # This method uses Faraday Multipart (lostisland/faraday-multipart)
      payload = {}
      payload[:statement] = Faraday::Multipart::FilePart.new(statement, "application/octet-stream")

      response = client.connection_upload.post "bank_transactions/statement?bank_account=#{bank_account}", payload
      response.success?
    end

    def delete(id:)
      response = delete_request("bank_transactions/#{id}")
      response.success?
    end
  end
end
