json.shopping_list_items do
  json.array! @shopping_list_items do |item|
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    json.id item.id
    json.name item.name
    json.ingredientId item.ingredient_id
    json.packagingForm item.packaging_form
    json.preparationStyle item.preparation_style
    json.brand item.brand
    json.displayName decorated.display_name
    json.displayNameWithBrand decorated.display_name_with_brand
    json.archivedAt item.archived_at
    json.archived item.archived?
    json.createdAt item.created_at
    json.updatedAt item.updated_at
  end
end
