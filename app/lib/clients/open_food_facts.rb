# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# Client for interacting with Open Food Facts API
# Returns Result objects with product data for barcodes
class Clients::OpenFoodFacts < Clients::BaseClient
    API_ENDPOINT = "https://world.openfoodfacts.net/api/v2/product"
    USER_AGENT = "Prep2Plate/1.0 (#{ENV.fetch('SUPPORT_EMAIL', 'prep2plateplanner@gmail.com')})"
    READ_TIMEOUT = 10
    OPEN_TIMEOUT = 5
    CLIENT_NAME = "Open Food Facts"

    def initialize(barcode)
      @barcode = barcode
    end

    def call
      response = make_api_request
      parsed = JSON.parse(response.body)

      if parsed["status"] == 1 && parsed["product"].present?
        success_result(parsed["product"])
      else
        Rails.logger.info("BARCODE_LOOKUP: Product not found for barcode #{@barcode}")
        error_result("Product not found in database. Please enter manually.")
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      error_result(
        "Request timed out. Please try again.",
        log_prefix: "BARCODE_LOOKUP: Timeout for barcode #{@barcode}"
      )
    rescue StandardError => e
      error_result(
        "An error occurred while looking up the product. Please try again.",
        log_prefix: "BARCODE_LOOKUP: API error for barcode #{@barcode}: #{e.class} - #{e.message}"
      )
    end

    private

    def make_api_request
      uri = URI.parse("#{API_ENDPOINT}/#{@barcode}")
      http = http_client(uri, read_timeout: READ_TIMEOUT, open_timeout: OPEN_TIMEOUT)
      request = Net::HTTP::Get.new(uri.path)
      request["User-Agent"] = USER_AGENT
      response = http.request(request)

      validate_response!(response, client_name: CLIENT_NAME)
      response
    end
end
