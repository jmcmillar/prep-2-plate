require 'net/http'
require 'json'
require 'uri'

module Products
  class OpenFoodFactsClient
    include Service

    API_ENDPOINT = "https://world.openfoodfacts.net/api/v2/product"
    USER_AGENT = "Prep2Plate/1.0 (#{ENV.fetch('SUPPORT_EMAIL', 'prep2plateplanner@gmail.com')})"
    READ_TIMEOUT = 10
    OPEN_TIMEOUT = 5

    class Result
      attr_reader :data, :success, :error_message

      def initialize(data:, success:, error_message:)
        @data = data
        @success = success
        @error_message = error_message
        freeze
      end

      def success?
        @success
      end
    end

    def initialize(barcode)
      @barcode = barcode
    end

    def call
      response = make_api_request
      parsed = JSON.parse(response.body)

      if parsed["status"] == 1 && parsed["product"].present?
        Result.new(data: parsed["product"], success: true, error_message: nil)
      else
        Rails.logger.info("BARCODE_LOOKUP: Product not found for barcode #{@barcode}")
        Result.new(
          data: nil,
          success: false,
          error_message: "Product not found in database. Please enter manually."
        )
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error("BARCODE_LOOKUP: Timeout for barcode #{@barcode}: #{e.message}")
      Result.new(
        data: nil,
        success: false,
        error_message: "Request timed out. Please try again."
      )
    rescue StandardError => e
      Rails.logger.error("BARCODE_LOOKUP: API error for barcode #{@barcode}: #{e.class} - #{e.message}")
      Result.new(
        data: nil,
        success: false,
        error_message: "An error occurred while looking up the product. Please try again."
      )
    end

    private

    def make_api_request
      uri = URI.parse("#{API_ENDPOINT}/#{@barcode}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = READ_TIMEOUT
      http.open_timeout = OPEN_TIMEOUT

      request = Net::HTTP::Get.new(uri.path)
      request["User-Agent"] = USER_AGENT

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise "Open Food Facts API request failed: #{response.code} #{response.message}"
      end

      response
    end
  end
end
