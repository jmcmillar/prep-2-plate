decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(@shopping_list_item)

json.id @shopping_list_item.id
json.name @shopping_list_item.name
json.ingredientId @shopping_list_item.ingredient_id
json.packagingForm @shopping_list_item.packaging_form
json.preparationStyle @shopping_list_item.preparation_style
json.brand @shopping_list_item.brand
json.displayName decorated.display_name
json.displayNameWithBrand decorated.display_name_with_brand
json.archivedAt @shopping_list_item.archived_at
json.archived @shopping_list_item.archived?
json.createdAt @shopping_list_item.created_at
json.updatedAt @shopping_list_item.updated_at
