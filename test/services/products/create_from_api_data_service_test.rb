require "test_helper"

class Products::CreateFromApiDataServiceTest < ActiveSupport::TestCase
  def setup
    @barcode = "1234567890123"
    @api_data = {
      "product_name" => "Test Product",
      "brands" => "Brand A, Brand B",
      "quantity" => "500g",
      "packaging" => "Plastic, Bottle",
      "extra_field" => "extra_value"
    }
  end

  def test_creates_product_with_complete_api_data
    product = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data
    )

    assert_kind_of Product, product
    assert product.persisted?
    assert_equal @barcode, product.barcode
    assert_equal "Test Product", product.name
    assert_equal "Brand A", product.brand
    assert_equal "500g", product.quantity
    assert_equal "Plastic", product.packaging
    assert_equal @api_data, product.raw_data
  end

  def test_extracts_product_name_from_product_name_field
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("product_name" => "Primary Name")
    )

    assert_equal "Primary Name", result.name
  end

  def test_extracts_product_name_from_product_name_en_when_product_name_missing
    api_data_without_product_name = @api_data.except("product_name").merge(
      "product_name_en" => "English Name"
    )

    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: api_data_without_product_name
    )

    assert_equal "English Name", result.name
  end

  def test_extracts_product_name_from_generic_name_when_other_names_missing
    api_data_minimal = @api_data.except("product_name", "product_name_en").merge(
      "generic_name" => "Generic Name"
    )

    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: api_data_minimal
    )

    assert_equal "Generic Name", result.name
  end

  def test_uses_unknown_product_when_all_name_fields_missing
    api_data_no_name = @api_data.except("product_name")

    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: api_data_no_name
    )

    assert_equal "Unknown Product", result.name
  end

  def test_uses_unknown_product_when_all_name_fields_blank
    api_data_blank_names = @api_data.merge(
      "product_name" => "",
      "product_name_en" => "   ",
      "generic_name" => nil
    )

    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: api_data_blank_names
    )

    assert_equal "Unknown Product", result.name
  end

  def test_extracts_first_brand_from_comma_separated_list
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("brands" => "Primary Brand, Secondary Brand, Third Brand")
    )

    assert_equal "Primary Brand", result.brand
  end

  def test_strips_whitespace_from_brand
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("brands" => "  Spaced Brand  ")
    )

    assert_equal "Spaced Brand", result.brand
  end

  def test_handles_nil_brand
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("brands" => nil)
    )

    assert_nil result.brand
  end

  def test_handles_empty_brand
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("brands" => "")
    )

    assert_nil result.brand
  end

  def test_extracts_first_packaging_from_comma_separated_list
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("packaging" => "Plastic, Recyclable, BPA-Free")
    )

    assert_equal "Plastic", result.packaging
  end

  def test_strips_whitespace_from_packaging
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("packaging" => "  Glass Bottle  ")
    )

    assert_equal "Glass Bottle", result.packaging
  end

  def test_handles_nil_packaging
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("packaging" => nil)
    )

    assert_nil result.packaging
  end

  def test_handles_empty_packaging
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("packaging" => "")
    )

    assert_nil result.packaging
  end

  def test_stores_quantity_as_provided
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("quantity" => "1L")
    )

    assert_equal "1L", result.quantity
  end

  def test_handles_nil_quantity
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data.merge("quantity" => nil)
    )

    assert_nil result.quantity
  end

  def test_stores_complete_raw_data
    result = Products::CreateFromApiDataService.call(
      barcode: @barcode,
      api_data: @api_data
    )

    assert_equal @api_data, result.raw_data
    assert_equal "extra_value", result.raw_data["extra_field"]
  end

  def test_creates_product_in_database
    assert_difference "Product.count", 1 do
      Products::CreateFromApiDataService.call(
        barcode: @barcode,
        api_data: @api_data
      )
    end
  end

  def test_raises_error_on_duplicate_barcode
    Product.create!(barcode: @barcode, name: "Existing Product")

    assert_raises ActiveRecord::RecordInvalid do
      Products::CreateFromApiDataService.call(
        barcode: @barcode,
        api_data: @api_data
      )
    end
  end

  def test_raises_error_when_barcode_missing
    assert_raises ActiveRecord::RecordInvalid do
      Products::CreateFromApiDataService.call(
        barcode: nil,
        api_data: @api_data
      )
    end
  end

  def test_raises_error_when_barcode_blank
    assert_raises ActiveRecord::RecordInvalid do
      Products::CreateFromApiDataService.call(
        barcode: "",
        api_data: @api_data
      )
    end
  end
end
