json.id @meal_plan.id
json.name @meal_plan.name
json.description @meal_plan.description
json.recipeCount @meal_plan.meal_plan_recipes.size
json.recipes do
  json.array! @meal_plan.meal_plan_recipes.order(:day_sequence, :date) do |meal_plan_recipe|
    json.id meal_plan_recipe.recipe.id
    json.name meal_plan_recipe.recipe.name
    json.imageUrl meal_plan_recipe.recipe.image.attached? ? rails_blob_url(meal_plan_recipe.recipe.image, host: request.host_with_port) : nil
    json.date meal_plan_recipe.date
    json.daySequence meal_plan_recipe.day_sequence
  end
end
