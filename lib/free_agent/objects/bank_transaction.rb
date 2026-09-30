module FreeAgent
  class BankTransaction < Object
    decimal_attributes :amount, :unexplained_amount

    def initialize(attributes)
      super

      # Convert amounts in bank_transaction_explanations to floats
      bank_transaction_explanations&.each do |explanation|
        %i[gross_value foreign_currency_value transfer_value].each do |name|
          explanation[name] = BigDecimal(explanation[name].to_s).to_f if explanation[name]
        end
      end
    end
  end
end
