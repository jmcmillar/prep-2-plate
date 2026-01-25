# frozen_string_literal: true

class Products::CreateFromApiDataService
  include Service

  def initialize(barcode:, api_data:)
    @barcode = barcode
    @api_data = api_data
  end

  def call
    Product.create!(
      barcode: @barcode,
      name: extract_product_name,
      brand: extract_brand,
      quantity: @api_data["quantity"],
      packaging: extract_packaging,
      raw_data: @api_data
    )
  end

  private

  def extract_product_name
    @api_data["product_name"].presence ||
      @api_data["product_name_en"].presence ||
      @api_data["generic_name"].presence ||
      "Unknown Product"
  end

  def extract_brand
    extract_first_value(@api_data["brands"])
  end

  def extract_packaging
    extract_first_value(@api_data["packaging"])
  end

  def extract_first_value(value)
    value&.split(",")&.first&.strip
  end
end
