json.shopping_list_items do
  json.array! @shopping_list_items do |item|
    json.id item.id
    json.name item.name
    json.ingredient_id item.ingredient_id
    json.packaging_form item.packaging_form
    json.preparation_style item.preparation_style
    json.display_name item.display_name
    json.archived_at item.archived_at
    json.archived item.archived?
    json.created_at item.created_at
    json.updated_at item.updated_at
  end
end
