module FreeAgent
  class CisSettingsResource < Resource
    def retrieve
      response = get_request("cis_settings")
      CisSettings.new(response.body["cis_settings"])
    end

    # Keys left out are unchanged. Set contractor_details or
    # subcontractor_details to nil to deregister.
    def update(**params)
      response = put_request("cis_settings", body: { cis_settings: params })
      CisSettings.new(response.body["cis_settings"]) if response.success?
    end
  end
end
