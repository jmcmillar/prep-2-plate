json.recipes do
  json.array! @recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.instructions recipe.recipe_instructions.order(:step_number).pluck(:instruction)
    json.imageUrl recipe.image.attached? ? rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png")
  end
end
