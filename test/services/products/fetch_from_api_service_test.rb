require "test_helper"

class Products::FetchFromApiServiceTest < ActiveSupport::TestCase
  def setup
    @barcode = "1234567890123"
    @api_data = {
      "product_name" => "Test Product",
      "brands" => "Test Brand",
      "quantity" => "500g",
      "packaging" => "Plastic bottle"
    }
  end

  def test_returns_success_with_product_when_api_succeeds
    api_result = Base::Result.new(data: @api_data, success: true, error_message: nil)

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }

    result = Products::FetchFromApiService.call(@barcode)

    assert_predicate result, :success?
    assert_kind_of Product, result.data
    assert_equal @barcode, result.data.barcode
    assert_equal "Test Product", result.data.name
    assert_equal "Test Brand", result.data.brand
    assert_nil result.error_message
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
  end

  def test_returns_failure_when_api_call_fails
    error_message = "API request failed"
    api_result = Base::Result.new(data: nil, success: false, error_message: error_message)

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }

    result = Products::FetchFromApiService.call(@barcode)

    assert_predicate result, :failure?
    assert_nil result.data
    assert_equal error_message, result.error_message
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
  end

  def test_logs_api_request
    api_result = Base::Result.new(data: @api_data, success: true, error_message: nil)

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }

    assert_logs_match(/BARCODE_LOOKUP: API request for barcode #{@barcode}/) do
      Products::FetchFromApiService.call(@barcode)
    end
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
  end

  def test_handles_product_creation_error
    api_result = Base::Result.new(data: @api_data, success: true, error_message: nil)

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }
    Products::CreateFromApiDataService.define_singleton_method(:call) { |**_args| raise StandardError.new("Database error") }

    result = Products::FetchFromApiService.call(@barcode)

    assert_predicate result, :failure?
    assert_nil result.data
    assert_equal "Failed to save product data. Please try again.", result.error_message
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
    Products::CreateFromApiDataService.singleton_class.send(:remove_method, :call)
  end

  def test_logs_product_creation_error
    api_result = Base::Result.new(data: @api_data, success: true, error_message: nil)
    error_message = "Database constraint violation"

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }
    Products::CreateFromApiDataService.define_singleton_method(:call) { |**_args| raise StandardError.new(error_message) }

    assert_logs_match(/BARCODE_LOOKUP: Error creating product #{@barcode}: #{error_message}/) do
      Products::FetchFromApiService.call(@barcode)
    end
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
    Products::CreateFromApiDataService.singleton_class.send(:remove_method, :call)
  end

  def test_creates_product_with_api_data
    api_result = Base::Result.new(data: @api_data, success: true, error_message: nil)

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }

    assert_difference "Product.count", 1 do
      Products::FetchFromApiService.call(@barcode)
    end

    product = Product.find_by(barcode: @barcode)
    assert_not_nil product
    assert_equal "Test Product", product.name
    assert_equal "Test Brand", product.brand
    assert_equal "500g", product.quantity
    assert_equal "Plastic bottle", product.packaging
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
  end

  def test_returns_result_object
    api_result = Base::Result.new(data: @api_data, success: true, error_message: nil)

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }

    result = Products::FetchFromApiService.call(@barcode)

    assert_kind_of Base::Result, result
    assert_respond_to result, :success?
    assert_respond_to result, :failure?
    assert_respond_to result, :data
    assert_respond_to result, :error_message
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
  end

  def test_handles_missing_product_name_gracefully
    api_data_no_name = @api_data.except("product_name")
    api_result = Base::Result.new(data: api_data_no_name, success: true, error_message: nil)

    Clients::OpenFoodFacts.define_singleton_method(:call) { |_barcode| api_result }

    result = Products::FetchFromApiService.call(@barcode)

    assert_predicate result, :success?
    # CreateFromApiDataService should handle missing name with "Unknown Product"
    assert_not_nil result.data.name
  ensure
    Clients::OpenFoodFacts.singleton_class.send(:remove_method, :call)
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
