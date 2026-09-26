class ShoppingListItem::DisplayNameWithBrandDecorator < Ingredient::DisplayNameDecorator
  # Display name with the brand in front
  # Examples:
  #   "tomatoes" (no brand)
  #   "Hunts canned diced tomatoes" (with brand)
  def display_name_with_brand
    brand.present? ? "#{brand} #{display_name}" : display_name
  end
end
