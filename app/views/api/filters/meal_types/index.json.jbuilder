json.mealTypes do
  json.array! @meal_types do |meal_type|
    json.id meal_type.id
    json.name meal_type.name
  end
end
