module FreeAgent
  class TimeslipsResource < Resource
    def list(**params)
      response = get_request("timeslips", params: params)
      Collection.from_response(response, type: Timeslip)
    end

    def list_for_user(user:, **params)
      response = get_request("timeslips?user=#{user}", params: params)
      Collection.from_response(response, type: Timeslip)
    end

    def list_for_task(task:, **params)
      response = get_request("timeslips?task=#{task}", params: params)
      Collection.from_response(response, type: Timeslip)
    end

    def list_for_project(project:, **params)
      response = get_request("timeslips?project=#{project}", params: params)
      Collection.from_response(response, type: Timeslip)
    end

    def retrieve(id:)
      response = get_request("timeslips/#{id}")
      Timeslip.new(response.body["timeslip"])
    end

    def create(task:, user:, project:, dated_on:, hours:, **params)
      attributes = { task: task, user: user, project: project, dated_on: dated_on, hours: hours }

      response = post_request("timeslips", body: { timeslip: attributes.merge(params) })
      Timeslip.new(response.body["timeslip"]) if response.success?
    end

    # Creates several timeslips in one request. Each is a hash of the same
    # attributes create takes.
    def create_many(timeslips:)
      response = post_request("timeslips", body: { timeslips: timeslips })
      response.success?
    end

    def update(id:, **params)
      response = put_request("timeslips/#{id}", body: { timeslip: params })
      Timeslip.new(response.body["timeslip"]) if response.success?
    end

    def delete(id:)
      response = delete_request("timeslips/#{id}")
      response.success?
    end

    def start_timer(id:)
      response = post_request("timeslips/#{id}/timer", body: {})
      Timeslip.new(response.body["timeslip"]) if response.success?
    end

    def stop_timer(id:)
      response = delete_request("timeslips/#{id}/timer")
      response.success?
    end
  end
end
