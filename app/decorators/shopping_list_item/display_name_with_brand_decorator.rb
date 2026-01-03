class ShoppingListItem::DisplayNameWithBrandDecorator < Ingredient::DisplayNameDecorator
  # Display name with brand appended in parentheses
  # Examples:
  #   "tomatoes" (no brand)
  #   "Canned Diced tomatoes (Hunts)" (with brand)
  def display_name_with_brand
    brand.present? ? "#{display_name} (#{brand})" : display_name
  end
end
