require "test_helper"

class ErrorGeneratorTest < Minitest::Test
  def test_error_factory_creates_correct_error_types
    assert_instance_of FreeAgent::Errors::BadRequestError,
                      FreeAgent::ErrorFactory.create({}, 400)
    assert_instance_of FreeAgent::Errors::AuthenticationMissingError,
                      FreeAgent::ErrorFactory.create({}, 401)
    assert_instance_of FreeAgent::Errors::ForbiddenError,
                      FreeAgent::ErrorFactory.create({}, 403)
    assert_instance_of FreeAgent::Errors::EntityNotFoundError,
                      FreeAgent::ErrorFactory.create({}, 404)
    assert_instance_of FreeAgent::Errors::ConflictError,
                      FreeAgent::ErrorFactory.create({}, 409)
    assert_instance_of FreeAgent::Errors::UnprocessableContent,
                      FreeAgent::ErrorFactory.create({}, 422)
    assert_instance_of FreeAgent::Errors::TooManyRequestsError,
                      FreeAgent::ErrorFactory.create({}, 429)
    assert_instance_of FreeAgent::Errors::InternalError,
                      FreeAgent::ErrorFactory.create({}, 500)
    assert_instance_of FreeAgent::Errors::NotImplementedError,
                      FreeAgent::ErrorFactory.create({}, 501)
    assert_instance_of FreeAgent::Errors::ServiceUnavailableError,
                      FreeAgent::ErrorFactory.create({}, 503)
  end

  def test_error_generator_with_array_errors
    response_body = {
      "errors" => [
        { "message" => "Name can't be blank" },
        { "message" => "Email is invalid" }
      ]
    }

    error = FreeAgent::ErrorGenerator.new(response_body, 422)

    assert_equal 422, error.http_status_code
    assert_equal "Name can't be blank, Email is invalid", error.freeagent_error_message
    assert_includes error.message, "Name can't be blank, Email is invalid"
  end

  def test_error_generator_with_nested_error
    response_body = {
      "errors" => {
        "error" => {
          "message" => "Resource not found"
        }
      }
    }

    error = FreeAgent::ErrorGenerator.new(response_body, 404)

    assert_equal 404, error.http_status_code
    assert_equal "Resource not found", error.freeagent_error_message
  end

  def test_error_generator_with_simple_message
    response_body = {
      "message" => "Server error occurred"
    }

    error = FreeAgent::ErrorGenerator.new(response_body, 500)

    assert_equal 500, error.http_status_code
    assert_equal "Server error occurred", error.freeagent_error_message
  end

  def test_bad_request_error_message
    error = FreeAgent::Errors::BadRequestError.new({ "errors" => [ { "message" => "Invalid data" } ] }, 400)

    assert_includes error.message, "Your request was malformed"
    assert_includes error.message, "Invalid data"
  end

  def test_authentication_missing_error_message
    error = FreeAgent::Errors::AuthenticationMissingError.new({}, 401)

    assert_includes error.message, "You did not supply valid authentication credentials"
  end

  def test_forbidden_error_message
    error = FreeAgent::Errors::ForbiddenError.new({}, 403)

    assert_includes error.message, "You are not allowed to perform that action"
  end

  def test_entity_not_found_error_message
    error = FreeAgent::Errors::EntityNotFoundError.new({}, 404)

    assert_includes error.message, "No results were found for your request"
  end

  def test_too_many_requests_error_message
    error = FreeAgent::Errors::TooManyRequestsError.new({}, 429)

    assert_includes error.message, "Your request exceeded the API rate limit"
  end

  def test_errors_without_a_body
    [ nil, "", "<html>Bad gateway</html>" ].each do |body|
      FreeAgent::ErrorFactory::HTTP_ERROR_MAP.each do |status, error_class|
        error = FreeAgent::ErrorFactory.create(body, status)

        assert_instance_of error_class, error
        assert_nil error.freeagent_error_message
        assert_match "Error #{status}", error.message
      end
    end
  end

  def test_conflict_without_a_body
    error = FreeAgent::ErrorFactory.create(nil, 409)

    assert_equal "Error 409: Your request was a conflict.", error.message
  end

  def test_unknown_error_without_a_body
    error = FreeAgent::ErrorGenerator.new(nil, 418)

    assert_equal "Error 418: An unknown error occurred.", error.message
  end
end
