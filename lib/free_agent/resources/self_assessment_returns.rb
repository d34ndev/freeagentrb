module FreeAgent
  class SelfAssessmentReturnsResource < Resource
    # Nested under a user, and identified by the date the period ends.
    # FreeAgent's docs call these Income Tax Returns.
    def list(user_id:, **params)
      response = get_request("users/#{user_id}/self_assessment_returns", params: params)
      Collection.from_response(response, type: SelfAssessmentReturn)
    end

    def retrieve(user_id:, period_ends_on:)
      response = get_request("users/#{user_id}/self_assessment_returns/#{period_ends_on}")
      SelfAssessmentReturn.new(response.body["self_assessment_return"])
    end

    def mark_as_filed(user_id:, period_ends_on:, **params)
      response = put_request("users/#{user_id}/self_assessment_returns/#{period_ends_on}/mark_as_filed", body: params)
      response.success?
    end

    def mark_as_unfiled(user_id:, period_ends_on:)
      response = put_request("users/#{user_id}/self_assessment_returns/#{period_ends_on}/mark_as_unfiled", body: {})
      response.success?
    end

    # A return can have several payments, each identified by its due_on date
    def mark_payment_as_paid(user_id:, period_ends_on:, payment_date:)
      response = put_request("users/#{user_id}/self_assessment_returns/#{period_ends_on}/payments/#{payment_date}/mark_as_paid", body: {})
      response.success?
    end

    def mark_payment_as_unpaid(user_id:, period_ends_on:, payment_date:)
      response = put_request("users/#{user_id}/self_assessment_returns/#{period_ends_on}/payments/#{payment_date}/mark_as_unpaid", body: {})
      response.success?
    end
  end
end
