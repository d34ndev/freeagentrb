module FreeAgent
  class BankAccountsResource < Resource
    def list(**params)
      response = get_request("bank_accounts", params: params)
      Collection.from_response(response, type: BankAccount)
    end

    def retrieve(id:)
      response = get_request("bank_accounts/#{id}")
      BankAccount.new(response.body["bank_account"])
    end

    def create(type: "StandardBankAccount", name:, opening_balance:, **params)
      attributes = { type: type, name: name, opening_balance: opening_balance }
      response = post_request("bank_accounts", body: { bank_account: attributes.merge(params) })
      BankAccount.new(response.body["bank_account"]) if response.success?
    end

    def update(id:, **params)
      response = put_request("bank_accounts/#{id}", body: { bank_account: params })
      BankAccount.new(response.body["bank_account"]) if response.success?
    end

    def delete(id:)
      response = delete_request("bank_accounts/#{id}")
      response.success?
    end
  end
end
