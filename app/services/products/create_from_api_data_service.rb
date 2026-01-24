module Products
  class CreateFromApiDataService
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
      @api_data["brands"]&.split(",")&.first&.strip
    end

    def extract_packaging
      @api_data["packaging"]&.split(",")&.first&.strip
    end
  end
end
