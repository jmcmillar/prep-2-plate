json.plannedMeals do
  json.array! @planned_meals do |planned_meal|
    json.id planned_meal.id
    json.date planned_meal.date.iso8601
    json.kind planned_meal.kind
    json.position planned_meal.position
    if planned_meal.recipe
      json.recipe do
        json.id planned_meal.recipe.id
        json.name planned_meal.recipe.name
        json.imageUrl planned_meal.recipe.image.attached? ? rails_blob_url(planned_meal.recipe.image, host: request.host_with_port) : nil
      end
    else
      json.recipe nil
    end
  end
end
