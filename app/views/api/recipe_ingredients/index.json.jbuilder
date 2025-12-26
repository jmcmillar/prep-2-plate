json.currentShoppingListId @facade.current_shopping_list_id
json.ingredientsByCategory do
  json.array! @facade.grouped_ingredients do |category, ingredients|
    json.categoryId category.id
    json.categoryName category.name
    json.ingredients do
      json.array! ingredients do |ingredient|
        json.id ingredient.id
        json.ingredientId ingredient.ingredient_id
        json.name ingredient.ingredient_name
        json.fullName ingredient.full_name
        json.packagingForm ingredient.packaging_form
        json.preparationStyle ingredient.preparation_style
        json.quantity ingredient.quantity
        json.recipeId ingredient.recipe_id
      end
    end
  end
end
