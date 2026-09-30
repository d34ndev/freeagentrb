module FreeAgent
  class UsersResource < Resource
    def me
      response = get_request("users/me")
      User.new(response.body["user"])
    end

    def list(**params)
      response = get_request("users", params: params)
      Collection.from_response(response, type: User)
    end

    def retrieve(id:)
      response = get_request("users/#{id}")
      User.new(response.body["user"])
    end

    def create(email:, first_name:, last_name:, role:, opening_mileage: 0, **params)
      attributes = { email: email, first_name: first_name, last_name: last_name, role: role, opening_mileage: opening_mileage }

      response = post_request("users", body: { user: attributes.merge(params) })
      User.new(response.body["user"]) if response.success?
    end

    def update(id:, **params)
      response = put_request("users/#{id}", body: { user: params })
      User.new(response.body["user"]) if response.success?
    end

    def update_me(**params)
      response = put_request("users/me", body: { user: params })
      User.new(response.body["user"]) if response.success?
    end

    def delete(id:)
      response = delete_request("users/#{id}")
      response.success?
    end
  end
end
