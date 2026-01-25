# frozen_string_literal: true

class Products::FetchFromApiService
  include Service

  def initialize(barcode)
    @barcode = barcode
  end

  def call
    log_api_request
    api_response = fetch_from_api

    return api_failure_result(api_response) if api_response.failure?

    create_product_from_response(api_response)
  rescue StandardError => e
    handle_product_creation_error(e)
  end

  private

  def log_api_request
    Rails.logger.info("BARCODE_LOOKUP: API request for barcode #{@barcode}")
  end

  def fetch_from_api
    Clients::OpenFoodFacts.call(@barcode)
  end

  def api_failure_result(api_response)
    failure_result(api_response.error_message)
  end

  def create_product_from_response(api_response)
    product = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: api_response.data
    )

    success_result(product)
  end

  def handle_product_creation_error(error)
    log_creation_error(error)
    failure_result("Failed to save product data. Please try again.")
  end

  def log_creation_error(error)
    Rails.logger.error("BARCODE_LOOKUP: Error creating product #{@barcode}: #{error.message}")
  end

  def success_result(product)
    Base::Result.new(data: product, success: true, error_message: nil)
  end

  def failure_result(error_message)
    Base::Result.new(data: nil, success: false, error_message: error_message)
  end
end
