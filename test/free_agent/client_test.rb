require "test_helper"

class ClientTest < Minitest::Test
  def test_access_token
    client = FreeAgent::Client.new access_token: "abc123"
    assert_equal "abc123", client.access_token
  end

  def test_subdomain_defaults_to_nil
    client = FreeAgent::Client.new access_token: "abc123"

    assert_nil client.subdomain
    assert_nil client.connection.headers["X-Subdomain"]
  end

  def test_subdomain_sets_header
    client = FreeAgent::Client.new access_token: "abc123", subdomain: "testcompany"

    assert_equal "testcompany", client.subdomain
    assert_equal "testcompany", client.connection.headers["X-Subdomain"]
  end

  def test_on_behalf_of_returns_scoped_client
    client = FreeAgent::Client.new access_token: "abc123", sandbox: true
    scoped = client.on_behalf_of("testcompany")

    assert_equal "testcompany", scoped.subdomain
    assert_equal "testcompany", scoped.connection.headers["X-Subdomain"]

    # The original client is left untouched
    assert_nil client.subdomain
    assert_nil client.connection.headers["X-Subdomain"]
  end

  def test_on_behalf_of_preserves_token_and_sandbox
    client = FreeAgent::Client.new access_token: "abc123", sandbox: true
    scoped = client.on_behalf_of("testcompany")

    assert_equal "abc123", scoped.access_token
    assert_equal true, scoped.sandbox
    assert_equal FreeAgent::Client::SANDBOX_BASE_URL, scoped.connection.url_prefix.to_s.chomp("/")
  end

  def test_upload_connection_is_separate_from_json_connection
    client = FreeAgent::Client.new access_token: "abc123", subdomain: "testcompany"

    refute_same client.connection, client.connection_upload
    assert_equal "testcompany", client.connection_upload.headers["X-Subdomain"]
  end

  def test_api_version_sets_header
    client = FreeAgent::Client.new access_token: "abc123", api_version: "2026-09-01"

    assert_equal "2026-09-01", client.connection.headers["X-Api-Version"]
    assert_equal "2026-09-01", client.connection_upload.headers["X-Api-Version"]
    assert_equal "2026-09-01", client.on_behalf_of("testcompany").api_version
  end

  def test_api_version_defaults_to_nil
    client = FreeAgent::Client.new access_token: "abc123"

    assert_nil client.connection.headers["X-Api-Version"]
  end
end
