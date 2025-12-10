json.recipeCategories do
  json.array! @facade.recipe_categories do |recipe_category|
    json.id recipe_category[:id]
    json.name recipe_category[:name]
    json.recipes do
      json.array! recipe_category[:recipes] do |recipe|
        json.id recipe.id
        json.name recipe.name
        json.imageUrl recipe.image.attached? ?  rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png", host: request.host_with_port)
        json.favorite @facade.recipe_favorite(recipe)
      end
    end
  end
end
