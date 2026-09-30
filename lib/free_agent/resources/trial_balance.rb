module FreeAgent
  class TrialBalanceResource < Resource
    def summary(**params)
      response = get_request("accounting/trial_balance/summary", params: params)
      Collection.from_response(response, type: TrialBalanceItem)
    end

    def opening_balances(**params)
      response = get_request("accounting/trial_balance/summary/opening_balances", params: params)
      Collection.from_response(response, type: TrialBalanceItem)
    end
  end
end
