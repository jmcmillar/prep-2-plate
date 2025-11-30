json.id @facade.id
json.name @facade.name
json.duration @facade.duration
json.servings @facade.servings
json.difficultyLevel @facade.difficulty_level
json.favorite @facade.favorite?
json.allowFavorite @facade.allow_favorite?
json.allowEdit @facade.allow_edit?
json.ingredients do
  json.array! @facade.ingredients do |ingredient|
    json.id ingredient.id
    json.name ingredient.ingredient_name
    json.quantity ingredient.quantity
    json.unit ingredient.measurement_unit
  end
end
json.instructions do
  json.array! @facade.instructions do |instruction|
    json.id instruction.id
    json.stepNumber instruction.step_number
    json.instruction instruction.instruction
  end
end
json.imageUrl @facade.recipe.image.attached? ?  rails_blob_url(@facade.recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png", host: request.host_with_port)
