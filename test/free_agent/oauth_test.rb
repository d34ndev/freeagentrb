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
    stub_request(:post, "https://api.sandbox.freeagent.com/v2//token_endpoint")
      .with(body: { client_id: "test_id", client_secret: "test_secret", grant_type: "authorization_code", code: "code", redirect_uri: "https://example.com" })
      .to_return(body: { access_token: "abc", refresh_token: "def", expires_in: 604800 }.to_json)

    oauth = FreeAgent::OAuth.new(client_id: "test_id", client_secret: "test_secret")
    token = oauth.token(code: "code", redirect: "https://example.com")

    assert_equal FreeAgent::Object, token.class
    assert_equal "abc", token.access_token
    assert_equal 604800, token.expires_in
  end
end
