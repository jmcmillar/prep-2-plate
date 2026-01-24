module Products
  class LookupService
    include Service

    # Immutable result object
    class Result
      attr_reader :product, :found, :message

      def initialize(product:, found:, message:)
        @product = product
        @found = found
        @message = message
        freeze
      end

      def success?
        @found
      end
    end

    def initialize(barcode)
      @barcode = barcode.to_s.strip
    end

    def call
      # Validate barcode format
      validation_result = Products::ValidateBarcodeService.call(@barcode)
      unless validation_result.valid?
        return Result.new(
          product: nil,
          found: false,
          message: validation_result.error_message
        )
      end

      # Check cache first
      cached_product = Product.find_by(barcode: @barcode)
      if cached_product
        Rails.logger.info("BARCODE_LOOKUP: Cache hit for barcode #{@barcode}")
        return Result.new(product: cached_product, found: true, message: nil)
      end

      # Fetch from external API
      api_result = Products::FetchFromApiService.call(@barcode)

      if api_result.success?
        Result.new(product: api_result.product, found: true, message: nil)
      else
        Result.new(product: nil, found: false, message: api_result.error_message)
      end
    end
  end
end
