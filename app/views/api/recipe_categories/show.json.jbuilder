json.id @facade.recipe_category&.id
json.name @facade.recipe_category&.name || "My Recipes"
json.recipes do
  json.array! @facade.recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe_image_url(recipe)
    json.favorite RecipeFavorite.find_by(user: Current.user, recipe: recipe).present?
  end
end
