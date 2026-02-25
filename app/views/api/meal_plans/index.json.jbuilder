json.mealPlans do
  json.array! @meal_plans do |meal_plan|
    json.id meal_plan.id
    json.name meal_plan.name
    json.recipeCount meal_plan.meal_plan_recipes.size
  end
end
