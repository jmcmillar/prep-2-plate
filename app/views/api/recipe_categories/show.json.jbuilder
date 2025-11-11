json.id @facade.recipe_category.id
json.name @facade.recipe_category.name
json.recipes do
  json.array! @facade.recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe.image.attached? ?  rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png", host: request.host_with_port)
    json.favorite RecipeFavorite.find_by(user: Current.user, recipe: recipe).present?
  end
end
