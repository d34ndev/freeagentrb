require "test_helper"

class ResourceTest < Minitest::Test
  def setup
    @client = FreeAgent::Client.new(access_token: "test_token")
    @resource = FreeAgent::Resource.new(@client)
  end

  def test_resource_initialization
    assert_equal @client, @resource.client
  end

  def test_error_detection
    assert @resource.send(:error?, double_response(400))
    assert @resource.send(:error?, double_response(401))
    assert @resource.send(:error?, double_response(403))
    assert @resource.send(:error?, double_response(404))
    assert @resource.send(:error?, double_response(409))
    assert @resource.send(:error?, double_response(422))
    assert @resource.send(:error?, double_response(429))
    assert @resource.send(:error?, double_response(500))
    assert @resource.send(:error?, double_response(501))
    assert @resource.send(:error?, double_response(503))

    refute @resource.send(:error?, double_response(200))
    refute @resource.send(:error?, double_response(201))
    refute @resource.send(:error?, double_response(204))
  end

  def test_error_detection_with_error_in_body
    assert @resource.send(:error?, double_response(200, { "error" => "Something went wrong" }))
  end

  def test_handle_response_success
    success_response = double_response(200, { "data" => "test" })
    result = @resource.send(:handle_response, success_response)

    assert_equal success_response, result
  end

  # Returned as-is, so callers can check response.success?
  def test_handle_response_no_content
    no_content_response = double_response(204, "")
    result = @resource.send(:handle_response, no_content_response)

    assert_equal no_content_response, result
  end

  def test_error_detection_with_a_non_json_body
    assert @resource.send(:error?, double_response(503, "<html>Service Unavailable</html>"))
    refute @resource.send(:error?, double_response(200, "OK"))
  end

  def test_handle_response_raises_error_on_failure
    error_response = double_response(404, { "errors" => { "error" => { "message" => "Not found" } } })

    assert_raises(FreeAgent::Errors::EntityNotFoundError) do
      @resource.send(:handle_response, error_response)
    end
  end

  private

  def double_response(status, body = {})
    response = Object.new
    response.define_singleton_method(:status) { status }
    response.define_singleton_method(:body) { body }
    response
  end
end
