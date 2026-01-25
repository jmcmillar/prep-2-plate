# frozen_string_literal: true

class Products::ValidateBarcodeService
  include Service

  BARCODE_FORMAT = /\A\d{8,14}\z/

  def initialize(barcode)
    @barcode = barcode.to_s.strip
  end

  def call
    return blank_barcode_error if barcode_blank?
    return invalid_format_error unless valid_format?

    success_result
  end

  private

  def barcode_blank?
    @barcode.blank?
  end

  def valid_format?
    @barcode.match?(BARCODE_FORMAT)
  end

  def blank_barcode_error
    failure_result("Barcode cannot be blank.")
  end

  def invalid_format_error
    failure_result("Invalid barcode format. Must be 8-14 digits.")
  end

  def success_result
    Base::Result.new(data: { valid: true }, success: true, error_message: nil)
  end

  def failure_result(error_message)
    Base::Result.new(
      data: { valid: false },
      success: false,
      error_message: error_message
    )
  end
end
