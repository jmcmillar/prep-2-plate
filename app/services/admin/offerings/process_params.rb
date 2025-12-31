module Admin
  module Offerings
    class ProcessParams
      include Service

      def initialize(params)
        @params = params
      end

      def call
        processed = @params.deep_dup

        process_ingredients(processed)

        processed
      end

      private

      def process_ingredients(processed)
        return unless processed[:offering_ingredients_attributes]

        processed[:offering_ingredients_attributes].each do |key, ingredient_attrs|
          next unless ingredient_attrs[:quantity].present?

          # Use QuantityFactory to convert quantity to Rational
          rational = QuantityFactory.new(ingredient_attrs[:quantity]).create

          # Set numerator and denominator
          ingredient_attrs[:numerator] = rational.numerator
          ingredient_attrs[:denominator] = rational.denominator

          # Remove the quantity field
          ingredient_attrs.delete(:quantity)
        end
      end
    end
  end
end
