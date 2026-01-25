class Products::LookupService
  include Service

  def initialize(barcode)
    @barcode = barcode.to_s.strip
  end

  def call
    validation_result = validate_barcode
    return validation_result if validation_result.failure?

    cached_product = find_cached_product
    return success_result(cached_product) if cached_product

    fetch_from_api
  end

  private

  def validate_barcode
    Products::ValidateBarcodeService.call(@barcode)
  end

  def find_cached_product
    Product.find_by(barcode: @barcode).tap do |product|
      log_cache_hit if product
    end
  end

  def log_cache_hit
    Rails.logger.info("BARCODE_LOOKUP: Cache hit for barcode #{@barcode}")
  end

  def fetch_from_api
    api_result = Products::FetchFromApiService.call(@barcode)

    if api_result.success?
      success_result(api_result.data)
    else
      failure_result(api_result.error_message)
    end
  end

  def success_result(data)
    Base::Result.new(data: data, success: true, error_message: nil)
  end

  def failure_result(error_message)
    Base::Result.new(data: nil, success: false, error_message: error_message)
  end
end
