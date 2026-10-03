json.favorites do
  json.array! @facade.favorite_recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe_image_url(recipe)
  end
end
json.importedRecipes do
  json.array! @facade.imported_recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe_image_url(recipe)
  end
end
json.userRecipes do
  json.array! @facade.user_recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe_image_url(recipe)
  end
end

