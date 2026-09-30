module FreeAgent
  class OAuth
    attr_reader :sandbox, :client_id, :client_secret

    def initialize(sandbox: true, client_id:, client_secret:)
      @sandbox = sandbox
      @client_id = client_id
      @client_secret = client_secret

      @base_url = sandbox ? "https://api.sandbox.freeagent.com/v2/" : "https://api.freeagent.com/v2/"
    end

    def authorise_url(redirect:, state: nil)
      url = "#{@base_url}/approve_app?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect}"
      url += "&state=#{state}" if state
      url
    end

    def token(code:, redirect:)
      send_request(url: "#{@base_url}/token_endpoint", body: {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect
      })
    end

    def refresh(refresh_token:)
      send_request(url: "#{@base_url}/token_endpoint", body: {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: "refresh_token",
        refresh_token: refresh_token
      })
    end

    private

    def send_request(url:, body:)
      response = Faraday.post(url, body)

      return false if response.status != 200

      FreeAgent::Object.new(JSON.parse(response.body))
    end
  end
end
