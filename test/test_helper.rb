$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "freeagentrb"

require "minitest/autorun"
require "faraday"
require "json"
require "webmock/minitest"

WebMock.disable_net_connect!

API_URL = "https://api.freeagent.com/v2".freeze
FIXTURES_DIR = File.expand_path("fixtures", __dir__).freeze

# Example responses from the FreeAgent API docs, downloaded by bin/fixtures,
# e.g. read_fixture("contacts/list_all_contacts")
def read_fixture(name)
  File.read(File.join(FIXTURES_DIR, "#{name}.json"))
end

module StubHelpers
  def client(**options)
    @client ||= FreeAgent::Client.new(access_token: "test_token", **options)
  end

  # request_body matches the JSON request body exactly, so stray attributes in
  # the body fail the stub. body can be a string or anything that converts to JSON.
  def stub_api(method, path, query: nil, request_body: nil, headers: nil, fixture: nil, status: 200, body: nil, response_headers: {})
    body = read_fixture(fixture) if fixture
    body = body.to_json unless body.nil? || body.is_a?(String)

    stub = stub_request(method, "#{API_URL}/#{path}")
    stub = stub.with(query: query) if query
    # WebMock treats an empty hash as "match anything", so compare empty bodies as a string
    stub = stub.with(body: request_body.empty? ? "{}" : request_body) if request_body
    stub = stub.with(headers: headers) if headers
    stub.to_return(status: status, body: body || "", headers: { "Content-Type" => "application/json" }.merge(response_headers))
  end
end

class Minitest::Test
  include StubHelpers
end
