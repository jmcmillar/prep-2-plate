json.userId @facade.user_id
# json.userName @facade.user_name
json.userName "User"
json.favorites do
  json.array! @facade.recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe.image.attached? ? rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png")
  end
end
json.recommendations do
  json.array! @facade.recommendations do |category|
    json.id category[:id]
    json.name category[:name]
    json.imageUrl rails_blob_url(category[:image_url], host: request.host_with_port) if category[:image_url].present?
    json.recipeCount category[:recipe_count]
  end
end
json.recipeCategories do
  json.array! @facade.recipe_categories do |category|
    json.id category.id
    json.name category.name
  end
end
json.todayRecipes do
  json.array! @facade.today_recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe.image.attached? ? rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png")
    json.durationMinutes recipe.duration_minutes
    json.difficultyLevel recipe.difficulty_level
  end
end
