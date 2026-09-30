require "test_helper"

class OAuthTest < Minitest::Test
  def test_oauth_initialization
    oauth = FreeAgent::OAuth.new(client_id: "test_id", client_secret: "test_secret")

    assert_equal "test_id", oauth.client_id
    assert_equal "test_secret", oauth.client_secret
  end

  def test_oauth_sandbox
    oauth_sandbox = FreeAgent::OAuth.new(sandbox: true, client_id: "test_id", client_secret: "test_secret")

    assert_equal "https://api.sandbox.freeagent.com/v2/", oauth_sandbox.instance_variable_get(:@base_url)
  end

  def test_oauth_production
    oauth_sandbox = FreeAgent::OAuth.new(sandbox: false, client_id: "test_id", client_secret: "test_secret")

    assert_equal "https://api.freeagent.com/v2/", oauth_sandbox.instance_variable_get(:@base_url)
  end

  def test_token_returns_an_object
    VCR.eject_cassette
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post("https://api.sandbox.freeagent.com/v2//token_endpoint") do
        [ 200, {}, JSON.dump({ "access_token" => "abc", "refresh_token" => "def", "expires_in" => 604800 }) ]
      end
    end
    original = Faraday.default_connection
    Faraday.default_connection = Faraday.new do |conn|
      conn.request :url_encoded
      conn.adapter :test, stubs
    end

    oauth = FreeAgent::OAuth.new(client_id: "test_id", client_secret: "test_secret")
    token = oauth.token(code: "code", redirect: "https://example.com")

    assert_equal FreeAgent::Object, token.class
    assert_equal "abc", token.access_token
    assert_equal 604800, token.expires_in
  ensure
    Faraday.default_connection = original
  end
end
