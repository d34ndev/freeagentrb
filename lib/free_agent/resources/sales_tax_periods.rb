module FreeAgent
  class SalesTaxPeriodsResource < Resource
    # US and Universal companies only
    def list(**params)
      response = get_request("sales_tax_periods", params: params)
      Collection.from_response(response, type: SalesTaxPeriod)
    end

    def retrieve(id:)
      response = get_request("sales_tax_periods/#{id}")
      SalesTaxPeriod.new(response.body["sales_tax_period"])
    end

    def create(sales_tax_name:, sales_tax_registration_status:, sales_tax_rate_1:, sales_tax_is_value_added:, effective_date:, **params)
      attributes = {
        sales_tax_name: sales_tax_name,
        sales_tax_registration_status: sales_tax_registration_status,
        sales_tax_rate_1: sales_tax_rate_1,
        sales_tax_is_value_added: sales_tax_is_value_added,
        effective_date: effective_date
      }

      response = post_request("sales_tax_periods", body: { sales_tax_period: attributes.merge(params) })
      SalesTaxPeriod.new(response.body["sales_tax_period"]) if response.success?
    end

    def update(id:, **params)
      response = put_request("sales_tax_periods/#{id}", body: { sales_tax_period: params })
      SalesTaxPeriod.new(response.body["sales_tax_period"]) if response.success?
    end

    def delete(id:)
      response = delete_request("sales_tax_periods/#{id}")
      response.success?
    end
  end
end
