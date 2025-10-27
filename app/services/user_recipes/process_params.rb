module UserRecipes
  class ProcessParams
    def initialize(params)
      @params = params
    end

    def call
      # Deep duplicate to avoid modifying the original params
      processed = @params.deep_dup
      
      process_ingredients(processed)
      
      processed
    end

    private

    def process_ingredients(processed)
      return unless processed.dig(:recipe_attributes, :recipe_ingredients_attributes)

      processed[:recipe_attributes][:recipe_ingredients_attributes].each do |key, ingredient_attrs|
        next unless ingredient_attrs[:quantity].present?
        
        # Use QuantityFactory to convert quantity to Rational, then extract numerator/denominator
        rational = QuantityFactory.new(ingredient_attrs[:quantity]).create
        
        # Set numerator and denominator from the Rational object
        ingredient_attrs[:numerator] = rational.numerator
        ingredient_attrs[:denominator] = rational.denominator
        
        # Remove the quantity field since we've converted it
        ingredient_attrs.delete(:quantity)
      end
    end
  end
end
