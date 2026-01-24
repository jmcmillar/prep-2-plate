module Products
  class FetchFromApiService
    include Service

    class Result
      attr_reader :product, :success, :error_message

      def initialize(product:, success:, error_message:)
        @product = product
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
      Rails.logger.info("BARCODE_LOOKUP: API request for barcode #{@barcode}")

      # Call Open Food Facts API
      api_response = Products::OpenFoodFactsClient.call(@barcode)

      unless api_response.success?
        return Result.new(
          product: nil,
          success: false,
          error_message: api_response.error_message
        )
      end

      # Create product from API data
      product = Products::CreateFromApiDataService.call(
        barcode: @barcode,
        api_data: api_response.data
      )

      Result.new(product: product, success: true, error_message: nil)
    rescue StandardError => e
      Rails.logger.error("BARCODE_LOOKUP: Error creating product #{@barcode}: #{e.message}")
      Result.new(
        product: nil,
        success: false,
        error_message: "Failed to save product data. Please try again."
      )
    end
  end
end
