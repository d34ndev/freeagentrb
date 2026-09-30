module FreeAgent
  class AccountManagersResource < Resource
    def list(**params)
      response = get_request("account_managers", params: params)
      Collection.from_response(response, type: AccountManager)
    end

    def retrieve(id:)
      response = get_request("account_managers/#{id}")
      AccountManager.new(response.body["account_manager"])
    end

    # The account manager the access token belongs to
    def me
      response = get_request("account_managers/me")
      AccountManager.new(response.body["account_manager"])
    end
  end
end
