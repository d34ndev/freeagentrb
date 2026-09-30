module FreeAgent
  class CompanyResource < Resource
    def retrieve
      response = get_request("company")
      Company.new(response.body["company"])
    end

    # The business categories a company can choose from, as strings
    def business_categories
      response = get_request("company/business_categories")
      response.body["business_categories"]
    end

    # Upcoming tax deadlines and payments
    def tax_timeline
      response = get_request("company/tax_timeline")
      Collection.from_response(response, type: TaxTimelineItem)
    end
  end
end
