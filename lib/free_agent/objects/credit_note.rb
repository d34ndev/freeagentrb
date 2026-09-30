module FreeAgent
  class CreditNote < Object
    decimal_attributes :net_value, :total_value, :refunded_value, :due_value, :sales_tax_value
  end
end
