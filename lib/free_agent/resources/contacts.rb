module FreeAgent
  class ContactsResource < Resource
    def list(**params)
      response = get_request("contacts", params: params)
      Collection.from_response(response, type: Contact)
    end

    def retrieve(id:)
      response = get_request("contacts/#{id}")
      Contact.new(response.body["contact"])
    end

    def create(**params)
      raise "first_name and last_name or organisation_name is required" unless !params[:first_name].nil? || !params[:organisation_name].nil?

      response = post_request("contacts", body: { contact: params })
      Contact.new(response.body["contact"]) if response.success?
    end

    def update(id:, **params)
      response = put_request("contacts/#{id}", body: { contact: params })
      Contact.new(response.body["contact"]) if response.success?
    end

    def delete(id:)
      response = delete_request("contacts/#{id}")
      response.success?
    end
  end
end
