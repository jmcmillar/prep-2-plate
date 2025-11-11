json.favorites do
  json.array! @facade.favorite_recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe.image.attached? ? rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png")
  end
end
json.importedRecipes do
  json.array! @facade.imported_recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe.image.attached? ? rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png")
  end
end
json.userRecipes do
  json.array! @facade.user_recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe.image.attached? ? rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png")
  end
end

