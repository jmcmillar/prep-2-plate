require "test_helper"

class Products::ValidateBarcodeServiceTest < ActiveSupport::TestCase
  def test_returns_failure_for_blank_barcode
    result = Products::ValidateBarcodeService.call("")

    assert_predicate result, :failure?
    assert_equal false, result.data[:valid]
    assert_equal "Barcode cannot be blank.", result.error_message
  end

  def test_returns_failure_for_nil_barcode
    result = Products::ValidateBarcodeService.call(nil)

    assert_predicate result, :failure?
    assert_equal false, result.data[:valid]
    assert_equal "Barcode cannot be blank.", result.error_message
  end

  def test_returns_failure_for_whitespace_only_barcode
    result = Products::ValidateBarcodeService.call("   ")

    assert_predicate result, :failure?
    assert_equal false, result.data[:valid]
    assert_equal "Barcode cannot be blank.", result.error_message
  end

  def test_returns_failure_for_barcode_with_letters
    result = Products::ValidateBarcodeService.call("abc123456789")

    assert_predicate result, :failure?
    assert_equal false, result.data[:valid]
    assert_equal "Invalid barcode format. Must be 8-14 digits.", result.error_message
  end

  def test_returns_failure_for_barcode_with_special_characters
    result = Products::ValidateBarcodeService.call("12345-67890")

    assert_predicate result, :failure?
    assert_equal false, result.data[:valid]
    assert_equal "Invalid barcode format. Must be 8-14 digits.", result.error_message
  end

  def test_returns_failure_for_barcode_too_short
    result = Products::ValidateBarcodeService.call("1234567")

    assert_predicate result, :failure?
    assert_equal false, result.data[:valid]
    assert_equal "Invalid barcode format. Must be 8-14 digits.", result.error_message
  end

  def test_returns_failure_for_barcode_too_long
    result = Products::ValidateBarcodeService.call("123456789012345")

    assert_predicate result, :failure?
    assert_equal false, result.data[:valid]
    assert_equal "Invalid barcode format. Must be 8-14 digits.", result.error_message
  end

  def test_returns_success_for_8_digit_barcode
    result = Products::ValidateBarcodeService.call("12345678")

    assert_predicate result, :success?
    assert_equal true, result.data[:valid]
    assert_nil result.error_message
  end

  def test_returns_success_for_13_digit_barcode_ean13
    result = Products::ValidateBarcodeService.call("1234567890123")

    assert_predicate result, :success?
    assert_equal true, result.data[:valid]
    assert_nil result.error_message
  end

  def test_returns_success_for_14_digit_barcode
    result = Products::ValidateBarcodeService.call("12345678901234")

    assert_predicate result, :success?
    assert_equal true, result.data[:valid]
    assert_nil result.error_message
  end

  def test_strips_whitespace_before_validation
    result = Products::ValidateBarcodeService.call("  1234567890123  ")

    assert_predicate result, :success?
    assert_equal true, result.data[:valid]
    assert_nil result.error_message
  end

  def test_returns_result_object
    result = Products::ValidateBarcodeService.call("1234567890123")

    assert_kind_of Base::Result, result
    assert_respond_to result, :success?
    assert_respond_to result, :failure?
    assert_respond_to result, :data
    assert_respond_to result, :error_message
  end
end
