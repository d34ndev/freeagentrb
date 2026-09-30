module FreeAgent
  class CashflowResource < Resource
    def retrieve(**params)
      response = get_request("cashflow", params: params)
      Cashflow.new(response.body["cashflow"])
    end
  end
end
