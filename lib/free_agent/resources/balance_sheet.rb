module FreeAgent
  class BalanceSheetResource < Resource
    # Defaults to today. Pass as_at_date or accounting_period (e.g. "2022/23")
    # for another date.
    def retrieve(**params)
      response = get_request("accounting/balance_sheet", params: params)
      BalanceSheet.new(response.body["balance_sheet"])
    end

    def opening_balances
      response = get_request("accounting/balance_sheet/opening_balances")
      BalanceSheet.new(response.body["balance_sheet"])
    end
  end
end
