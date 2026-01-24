module Products
  class ValidateBarcodeService
    include Service

    class Result
      attr_reader :valid, :error_message

      def initialize(valid:, error_message:)
        @valid = valid
        @error_message = error_message
        freeze
      end

      def valid?
        @valid
      end
    end

    BARCODE_FORMAT = /\A\d{8,14}\z/

    def initialize(barcode)
      @barcode = barcode.to_s.strip
    end

    def call
      if @barcode.blank?
        return Result.new(
          valid: false,
          error_message: "Barcode cannot be blank."
        )
      end

      if @barcode.match?(BARCODE_FORMAT)
        Result.new(valid: true, error_message: nil)
      else
        Result.new(
          valid: false,
          error_message: "Invalid barcode format. Must be 8-14 digits."
        )
      end
    end
  end
end
