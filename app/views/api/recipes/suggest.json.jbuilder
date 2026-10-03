json.suggestions do
  json.array! @facade.recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe_image_url(recipe)
  end
end
