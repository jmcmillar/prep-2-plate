decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(@shopping_list_item)

json.id @shopping_list_item.id
json.name @shopping_list_item.name
json.ingredient_id @shopping_list_item.ingredient_id
json.packaging_form @shopping_list_item.packaging_form
json.preparation_style @shopping_list_item.preparation_style
json.brand @shopping_list_item.brand
json.display_name decorated.display_name
json.display_name_with_brand decorated.display_name_with_brand
json.archived_at @shopping_list_item.archived_at
json.archived @shopping_list_item.archived?
json.created_at @shopping_list_item.created_at
json.updated_at @shopping_list_item.updated_at
