# frozen_string_literal: true

require 'net/http'

class Clients::BaseClient
  include Service

  private

    # Creates configured HTTP client with SSL and timeouts
    # @param uri [URI] The URI to connect to
    # @param read_timeout [Integer] Seconds to wait for response
    # @param open_timeout [Integer] Seconds to wait for connection
    # @return [Net::HTTP] Configured HTTP client
    def http_client(uri, read_timeout: 30, open_timeout: 10)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = read_timeout
      http.open_timeout = open_timeout
      http
    end

    # Validates HTTP response is successful
    # @param response [Net::HTTPResponse] The response to validate
    # @param client_name [String] Name of client for logging
    # @raise [StandardError] If response is not HTTPSuccess
    def validate_response!(response, client_name:)
      return if response.is_a?(Net::HTTPSuccess)

      error_msg = "#{client_name} API request failed: #{response.code} #{response.message}"
      Rails.logger.error(error_msg)
      raise StandardError, error_msg
    end

    # Wraps data in successful Result object
    # @param data [Object] The successful response data
    # @return [Result] Success result with data
    def success_result(data)
      Base::Result.new(data: data, success: true, error_message: nil)
    end

    # Wraps error in failure Result object with optional logging
    # @param message [String] User-friendly error message
    # @param log_prefix [String] Optional log prefix for detailed logging
    # @return [Result] Failure result with error message
    def error_result(message, log_prefix: nil)
      Rails.logger.error("#{log_prefix}: #{message}") if log_prefix
      Base::Result.new(data: nil, success: false, error_message: message)
    end
end
