class MealPlanIngredient::DisplayDecorator < BaseDecorator
  # Full name with packaging, preparation, and quantity
  # Example: "canned diced tomatoes (2 cups)"
  def full_name
    "#{ingredient_display_name} (#{formatted_quantity})"
  end

  # Ingredient name with packaging and preparation
  # Example: "canned diced tomatoes"
  def ingredient_display_name
    parts = []
    parts << Ingredient::PACKAGING_FORMS[packaging_form.to_sym] if packaging_form.present?
    parts << Ingredient::PREPARATION_STYLES[preparation_style.to_sym] if preparation_style.present?
    parts << name
    parts.join(" ").downcase
  end

  # Formatted quantity with unit
  # Example: "2 cups"
  def formatted_quantity
    [formatted_amount, unit_name].compact.join(" ")
  end

  # Pluralized unit name based on quantity
  def unit_name
    return unless @object.unit_name.present?
    return @object.unit_name if less_than_one?

    @object.unit_name.pluralize(quantity)
  end

  # Check if quantity is less than one (for pluralization)
  def less_than_one?
    quantity.zero? && formatted_amount.present?
  end

  private

  def packaging_form
    @object.packaging_form
  end

  def preparation_style
    @object.preparation_style
  end
end
