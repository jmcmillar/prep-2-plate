json.recipes do
  json.array! @recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.instructions recipe.recipe_instructions.order(:step_number).pluck(:instruction)
    json.imageUrl recipe_image_url(recipe)
  end
end
