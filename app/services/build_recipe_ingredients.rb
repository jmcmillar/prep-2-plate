class BuildRecipeIngredients
  include Service
  AttributeData = Struct.new(:quantity, :measurement_unit_id, :ingredient, :notes)

  def initialize(recipe_id, attributes)
    @recipe_id = recipe_id
    @attributes = attributes
  end

  def call
    build_records
  end

  def build_records
    attribute_data_array.each do |attribute_data|
      set_ingredient(attribute_data).recipe_ingredients.new(
        recipe_id: @recipe_id,
        measurement_unit_id: attribute_data.measurement_unit_id,
        denominator: Recipes::ParseQuantity.new(attribute_data.quantity).to_value.denominator,
        numerator: Recipes::ParseQuantity.new(attribute_data.quantity).to_value.numerator,
        notes: attribute_data.notes
      ).save
    end
  end

  def set_ingredient(attribute_data)
    Ingredient.where(name: attribute_data.ingredient.downcase).first_or_create!
  end

  def attribute_data_array
    @attributes.map { |attribute| build_attribute_data(attribute) }.compact
  end

  def build_attribute_data(attribute)
    AttributeData[
      attribute[:quantity],
      attribute[:measurement_unit_id],
      attribute[:ingredient_name],
      attribute[:ingredient_notes]
    ]
  end
end
