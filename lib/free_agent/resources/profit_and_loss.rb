module FreeAgent
  class ProfitAndLossResource < Resource
    # Defaults to the current accounting year to date. Pass from_date and
    # to_date, or accounting_period (e.g. "2022/23"), for another period.
    def summary(**params)
      response = get_request("accounting/profit_and_loss/summary", params: params)
      ProfitAndLoss.new(response.body["profit_and_loss_summary"])
    end
  end
end
