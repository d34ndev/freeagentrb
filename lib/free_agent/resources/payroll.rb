module FreeAgent
  class PayrollResource < Resource
    # Payroll is organised by tax year, then by period within that year
    def list(year:, **params)
      response = get_request("payroll/#{year}", params: params)
      Collection.from_response(response, type: PayrollPeriod)
    end

    # The PAYE payments due to HMRC for a tax year, each identified by its
    # due_on date
    def payments(year:)
      response = get_request("payroll/#{year}")
      response.body["payments"].map { |attributes| FreeAgent::Object.new(attributes) }
    end

    # The period, with its payslips
    def retrieve(year:, period:)
      response = get_request("payroll/#{year}/#{period}")
      PayrollPeriod.new(response.body["period"])
    end

    def mark_payment_as_paid(year:, payment_date:)
      response = put_request("payroll/#{year}/payments/#{payment_date}/mark_as_paid", body: {})
      response.success?
    end

    def mark_payment_as_unpaid(year:, payment_date:)
      response = put_request("payroll/#{year}/payments/#{payment_date}/mark_as_unpaid", body: {})
      response.success?
    end
  end
end
