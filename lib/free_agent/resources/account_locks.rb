module FreeAgent
  class AccountLocksResource < Resource
    # Returns the company's account locks, along with earliest_lock_date and
    # latest_lock_date, the range a user account lock can be set within
    def retrieve
      response = get_request("account_locks")
      locks = FreeAgent::Object.new(response.body)
      locks.account_locks = response.body["account_locks"].map { |attributes| AccountLock.new(attributes) }
      locks
    end

    # Creates or updates the user account lock
    def update(locked_to_date:)
      response = put_request("account_locks", body: { account_lock: { locked_to_date: locked_to_date } })
      response.success?
    end

    # Removes the user account lock
    def delete
      response = delete_request("account_locks")
      response.success?
    end
  end
end
