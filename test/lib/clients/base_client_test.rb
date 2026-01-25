require "test_helper"

class Clients::BaseClientTest < ActiveSupport::TestCase
  class TestClient < Clients::BaseClient
    # Expose private methods for testing
    def test_http_client(uri, **options)
      http_client(uri, **options)
    end

    def test_validate_response!(response)
      validate_response!(response, client_name: "TestClient")
    end

    def test_success_result(data)
      success_result(data)
    end

    def test_error_result(message, log_prefix: nil)
      error_result(message, log_prefix: log_prefix)
    end
  end

  def setup
    @client = TestClient.new
    @uri = URI("https://api.example.com/test")
  end

  def test_includes_service_module
    assert TestClient.respond_to?(:call), "Should include Service module with .call class method"
  end

  def test_http_client_creates_http_instance
    http = @client.test_http_client(@uri)

    assert_instance_of Net::HTTP, http
    assert_equal "api.example.com", http.address
    assert_equal 443, http.port
  end

  def test_http_client_enables_ssl
    http = @client.test_http_client(@uri)

    assert http.use_ssl?, "SSL should be enabled"
  end

  def test_http_client_sets_default_timeouts
    http = @client.test_http_client(@uri)

    assert_equal 30, http.read_timeout
    assert_equal 10, http.open_timeout
  end

  def test_http_client_accepts_custom_read_timeout
    http = @client.test_http_client(@uri, read_timeout: 60)

    assert_equal 60, http.read_timeout
  end

  def test_http_client_accepts_custom_open_timeout
    http = @client.test_http_client(@uri, open_timeout: 5)

    assert_equal 5, http.open_timeout
  end

  def test_validate_response_accepts_success_response
    response = Net::HTTPOK.new("1.1", "200", "OK")

    assert_nothing_raised do
      @client.test_validate_response!(response)
    end
  end

  def test_validate_response_raises_on_error_response
    response = Net::HTTPNotFound.new("1.1", "404", "Not Found")

    error = assert_raises(StandardError) do
      @client.test_validate_response!(response)
    end

    assert_match(/TestClient API request failed: 404 Not Found/, error.message)
  end

  def test_validate_response_logs_error
    response = Net::HTTPBadRequest.new("1.1", "400", "Bad Request")

    # Capture log output
    logger_output = StringIO.new
    original_logger = Rails.logger
    Rails.logger = Logger.new(logger_output)

    assert_raises(StandardError) do
      @client.test_validate_response!(response)
    end

    assert_match(/TestClient API request failed: 400 Bad Request/, logger_output.string)
  ensure
    Rails.logger = original_logger
  end

  def test_success_result_creates_success_result
    data = {foo: "bar"}
    result = @client.test_success_result(data)

    assert_instance_of Base::Result, result
    assert result.success?
    refute result.failure?
    assert_equal data, result.data
    assert_nil result.error_message
  end

  def test_error_result_creates_failure_result
    message = "Something went wrong"
    result = @client.test_error_result(message)

    assert_instance_of Base::Result, result
    refute result.success?
    assert result.failure?
    assert_nil result.data
    assert_equal message, result.error_message
  end

  def test_error_result_logs_with_prefix
    message = "API error"
    log_prefix = "TEST_CLIENT"

    # Capture log output
    logger_output = StringIO.new
    original_logger = Rails.logger
    Rails.logger = Logger.new(logger_output)

    @client.test_error_result(message, log_prefix: log_prefix)

    assert_match(/#{log_prefix}: #{message}/, logger_output.string)
  ensure
    Rails.logger = original_logger
  end

  def test_error_result_does_not_log_without_prefix
    message = "API error"

    # Capture log output
    logger_output = StringIO.new
    original_logger = Rails.logger
    Rails.logger = Logger.new(logger_output)

    @client.test_error_result(message)

    # Should not contain any log output for this specific message
    assert_equal "", logger_output.string
  ensure
    Rails.logger = original_logger
  end
end
