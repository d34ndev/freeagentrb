module FreeAgent
  class ErrorGenerator < StandardError
    attr_reader :http_status_code
    attr_reader :freeagent_error_code
    attr_reader :freeagent_error_message

    def initialize(response_body, http_status_code)
      @response_body = response_body
      @http_status_code = http_status_code
      set_freeagent_error_values
      super(build_message)
    end

    private

    # Parse the FreeAgent error code and message from the response body
    def set_freeagent_error_values
      return unless @response_body.is_a?(Hash)
      if @response_body.dig("errors") && @response_body.dig("errors").is_a?(Array)
        @freeagent_error_message = @response_body.dig("errors").map { |error| error["message"] }.join(", ")
      elsif @response_body.dig("errors", "error", "message")
        @freeagent_error_message = @response_body.dig("errors", "error", "message")
      else
        @freeagent_error_message = @response_body.dig("message")
      end
    end

    # Some errors, such as a 409 when deleting a sent invoice, come with no
    # body at all
    def error_message
      @freeagent_error_message || (@response_body["error"] if @response_body.is_a?(Hash)) || "An unknown error occurred."
    end

    def build_message
      if freeagent_error_code.nil?
        return "Error #{@http_status_code}: #{error_message}"
      end
      "Error #{@http_status_code}: #{error_message} '#{freeagent_error_message}'"
    end
  end

  module Errors
    class BadRequestError < ErrorGenerator
      private

      def error_message
        "Your request was malformed. '#{freeagent_error_message}'"
      end
    end

    class AuthenticationMissingError < ErrorGenerator
      private

      def error_message
        "You did not supply valid authentication credentials."
      end
    end

    class ForbiddenError < ErrorGenerator
      private

      def error_message
        "You are not allowed to perform that action."
      end
    end

    class EntityNotFoundError < ErrorGenerator
      private

      def error_message
        "No results were found for your request."
      end
    end

    class ConflictError < ErrorGenerator
      private

      def error_message
        "Your request was a conflict."
      end
    end

    class UnprocessableContent < ErrorGenerator
      private

      def error_message
        "Your request was unprocessable. '#{freeagent_error_message}'"
      end
    end

    class TooManyRequestsError < ErrorGenerator
      private

      def error_message
        "Your request exceeded the API rate limit."
      end
    end

    class InternalError < ErrorGenerator
      private

      def error_message
        "We were unable to perform the request due to server-side problems."
      end
    end

    class ServiceUnavailableError < ErrorGenerator
      private

      def error_message
        "You have been rate limited for sending more than 20 requests per second."
      end
    end

    class NotImplementedError < ErrorGenerator
      private

      def error_message
        "This resource has not been implemented."
      end
    end
  end

  class ErrorFactory
    HTTP_ERROR_MAP = {
      400 => Errors::BadRequestError,
      401 => Errors::AuthenticationMissingError,
      403 => Errors::ForbiddenError,
      404 => Errors::EntityNotFoundError,
      409 => Errors::ConflictError,
      422 => Errors::UnprocessableContent,
      429 => Errors::TooManyRequestsError,
      500 => Errors::InternalError,
      503 => Errors::ServiceUnavailableError,
      501 => Errors::NotImplementedError
    }.freeze

    def self.create(response_body, http_status_code)
      status = http_status_code
      error_class = HTTP_ERROR_MAP[status] || ErrorGenerator
      error_class.new(response_body, http_status_code) if error_class
    end
  end
end
