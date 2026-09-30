$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "freeagentrb"
require "minitest/autorun"
require "faraday"
require "json"
require "vcr"
require "dotenv/load"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :faraday

  config.filter_sensitive_data("<AUTHORIZATION>") { ENV["FREEAGENT_ACCESS_TOKEN"] }

  # Tests built on stub_client eject their cassette and use Faraday's test
  # adapter instead, so no real connection is made without a cassette.
  config.allow_http_connections_when_no_cassette = true
end

def setup_client
  @client ||= FreeAgent::Client.new(access_token: ENV["FREEAGENT_ACCESS_TOKEN"], sandbox: true)
end

# Builds a client backed by Faraday's test adapter, for asserting on the
# request itself (path, body) rather than on a recorded response. Ejects the
# cassette inserted by setup, so that VCR doesn't record the stubbed responses.
def stub_client(**options)
  VCR.eject_cassette if VCR.current_cassette

  stubs = Faraday::Adapter::Test::Stubs.new
  yield stubs
  @stubs = stubs
  FreeAgent::Client.new(access_token: "test_token", adapter: :test, stubs: stubs, **options)
end

# Shorthand for a stubbed JSON response triplet
def json(body, status: 200)
  [ status, { "Content-Type" => "application/json" }, JSON.dump(body) ]
end

class Minitest::Test
  def setup
    VCR.insert_cassette(name)
  end

  def teardown
    VCR.eject_cassette if VCR.current_cassette
    @stubs&.verify_stubbed_calls
  end
end
