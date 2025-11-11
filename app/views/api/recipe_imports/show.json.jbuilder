json.name @facade.recipe[:name]
json.duration @facade.recipe[:total_time]
json.servings "Unknown"
json.difficultyLevel "Unknown"
json.favorite false
json.allowFavorite false
json.ingredients do
  json.array! @facade.recipe[:ingredients]
end
json.instructions do
  json.array! @facade.recipe[:instructions]
end
json.imageUrl image_url("no-recipe-image.png", host: request.host_with_port)
