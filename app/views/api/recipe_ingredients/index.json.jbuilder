json.currentShoppingListId @facade.current_shopping_list_id
json.ingredients do
  json.array! @facade.recipe_ingredients do |ingredient|
    json.id ingredient.id
    json.name ingredient.full_name
    json.quantity ingredient.quantity
    json.recipeId ingredient.recipe_id
  end
end
