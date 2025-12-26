json.shopping_list_items do
  json.array! @shopping_list_items do |item|
    json.id item.id
    json.name item.name
    json.ingredientId item.ingredient_id
    json.packagingForm item.packaging_form
    json.preparationStyle item.preparation_style
    json.displayName item.display_name
    json.createdAt item.created_at
    json.updatedAt item.updated_at
  end
end
