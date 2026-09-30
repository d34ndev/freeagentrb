module FreeAgent
  class ProfitAndLoss < Object
    decimal_attributes :income, :expenses, :operating_profit, :retained_profit,
      :retained_profit_brought_forward, :retained_profit_carried_forward
  end
end
