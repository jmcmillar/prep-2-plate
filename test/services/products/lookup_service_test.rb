require "test_helper"

class Products::LookupServiceTest < ActiveSupport::TestCase
  def setup
    @valid_barcode = "1234567890123"
    @invalid_barcode = "abc123"
  end

  def test_returns_validation_error_for_blank_barcode
    result = Products::LookupService.call("")

    assert_predicate result, :failure?
    assert_equal({ valid: false }, result.data)
    assert_equal "Barcode cannot be blank.", result.error_message
  end

  def test_returns_validation_error_for_invalid_barcode_format
    result = Products::LookupService.call(@invalid_barcode)

    assert_predicate result, :failure?
    assert_equal({ valid: false }, result.data)
    assert_equal "Invalid barcode format. Must be 8-14 digits.", result.error_message
  end

  def test_returns_cached_product_when_exists
    product = Product.create!(
      barcode: @valid_barcode,
      name: "Test Product",
      brand: "Test Brand"
    )

    result = Products::LookupService.call(@valid_barcode)

    assert_predicate result, :success?
    assert_equal product.id, result.data.id
    assert_equal @valid_barcode, result.data.barcode
    assert_nil result.error_message
  end

  def test_logs_cache_hit_when_product_exists
    Product.create!(
      barcode: @valid_barcode,
      name: "Test Product",
      brand: "Test Brand"
    )

    assert_logs_match(/BARCODE_LOOKUP: Cache hit for barcode #{@valid_barcode}/) do
      Products::LookupService.call(@valid_barcode)
    end
  end

  def test_fetches_from_api_when_product_not_cached
    api_data = {
      "product_name" => "New Product",
      "brands" => "New Brand",
      "quantity" => "500g",
      "packaging" => "Plastic"
    }

    # Mock the FetchFromApiService since we don't want to hit the actual API
    product = Product.new(
      id: 999,
      barcode: @valid_barcode,
      name: "New Product",
      brand: "New Brand",
      quantity: "500g",
      packaging: "Plastic"
    )
    fetch_result = Base::Result.new(data: product, success: true, error_message: nil)

    Products::FetchFromApiService.define_singleton_method(:call) { |_barcode| fetch_result }

    result = Products::LookupService.call(@valid_barcode)

    assert_predicate result, :success?
    assert_kind_of Product, result.data
    assert_equal @valid_barcode, result.data.barcode
    assert_equal "New Product", result.data.name
    assert_nil result.error_message
  ensure
    Products::FetchFromApiService.singleton_class.send(:remove_method, :call)
  end

  def test_returns_api_error_when_fetch_fails
    error_message = "API is unavailable"
    fetch_result = Base::Result.new(data: nil, success: false, error_message: error_message)

    Products::FetchFromApiService.define_singleton_method(:call) { |_barcode| fetch_result }

    result = Products::LookupService.call(@valid_barcode)

    assert_predicate result, :failure?
    assert_nil result.data
    assert_equal error_message, result.error_message
  ensure
    Products::FetchFromApiService.singleton_class.send(:remove_method, :call)
  end

  def test_strips_whitespace_from_barcode
    product = Product.create!(
      barcode: @valid_barcode,
      name: "Test Product",
      brand: "Test Brand"
    )

    result = Products::LookupService.call("  #{@valid_barcode}  ")

    assert_predicate result, :success?
    assert_equal product.id, result.data.id
  end

  def test_returns_result_object
    result = Products::LookupService.call("")

    assert_kind_of Base::Result, result
    assert_respond_to result, :success?
    assert_respond_to result, :failure?
    assert_respond_to result, :data
    assert_respond_to result, :error_message
  end

  private

  def assert_logs_match(pattern)
    old_logger = Rails.logger
    log_output = StringIO.new
    Rails.logger = Logger.new(log_output)

    yield

    assert_match pattern, log_output.string
  ensure
    Rails.logger = old_logger
  end
end
