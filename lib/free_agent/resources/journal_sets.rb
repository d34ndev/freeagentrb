module FreeAgent
  class JournalSetsResource < Resource
    def list(**params)
      response = get_request("journal_sets", params: params)
      Collection.from_response(response, type: JournalSet)
    end

    # A single journal set, with the opening balances for bank accounts and
    # stock items alongside its journal entries
    def opening_balances
      response = get_request("journal_sets/opening_balances")
      JournalSet.new(response.body["journal_set"])
    end

    def retrieve(id:)
      response = get_request("journal_sets/#{id}")
      JournalSet.new(response.body["journal_set"])
    end

    def create(dated_on:, description:, journal_entries:, **params)
      attributes = { dated_on: dated_on, description: description, journal_entries: journal_entries }

      response = post_request("journal_sets", body: { journal_set: attributes.merge(params) })
      JournalSet.new(response.body["journal_set"]) if response.success?
    end

    def update(id:, **params)
      response = put_request("journal_sets/#{id}", body: { journal_set: params })
      JournalSet.new(response.body["journal_set"]) if response.success?
    end

    def delete(id:)
      response = delete_request("journal_sets/#{id}")
      response.success?
    end
  end
end
