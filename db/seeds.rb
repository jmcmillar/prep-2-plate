# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Only run seed data in development and test environments
return unless Rails.env.development? || Rails.env.test?

puts "🌱 Seeding database for #{Rails.env} environment..."

# Clean up existing data (development only)
if Rails.env.development?
  puts "  Cleaning up existing data..."
  ShoppingListItem.delete_all
  ShoppingList.delete_all
  MealPlanRecipe.delete_all
  UserMealPlan.delete_all
  MealPlan.delete_all
  RecipeFavorite.delete_all
  UserRecipe.delete_all
  RecipeIngredient.delete_all
  Recipe.delete_all
  Ingredient.delete_all
  IngredientCategory.delete_all
  MeasurementUnitAlias.delete_all
  MeasurementUnit.delete_all
  Session.delete_all
  User.delete_all
end

# Create ingredient categories
puts "  Creating ingredient categories..."
categories = {
  "Produce" => %w[Fruits Vegetables],
  "Proteins" => %w[Meat Poultry Seafood],
  "Dairy" => %w[Milk Cheese Yogurt],
  "Pantry" => %w[Grains Spices Oils],
  "Frozen" => %w[Vegetables Desserts]
}

ingredient_categories = {}
categories.each do |parent, _subcats|
  ingredient_categories[parent] = IngredientCategory.find_or_create_by!(name: parent)
end

# Create measurement units with aliases
puts "  Creating measurement units with aliases..."
measurement_units_data = {
  # Volume - Metric
  "liter" => ["l", "litre", "litres", "liters"],
  "milliliter" => ["ml", "millilitre", "millilitres", "milliliters"],

  # Volume - US/Imperial
  "cup" => ["c", "cups"],
  "tablespoon" => ["tbsp", "tbs", "T", "tablespoons"],
  "teaspoon" => ["tsp", "t", "teaspoons"],
  "fluid ounce" => ["fl oz", "fl. oz.", "fluid ounces"],
  "pint" => ["pt", "pints"],
  "quart" => ["qt", "quarts"],
  "gallon" => ["gal", "gallons"],

  # Weight - Metric
  "gram" => ["g", "grams"],
  "kilogram" => ["kg", "kilo", "kilos", "kilograms"],
  "milligram" => ["mg", "milligrams"],

  # Weight - US/Imperial
  "pound" => ["lb", "lbs", "pounds"],
  "ounce" => ["oz", "ounces"],

  # Length
  "inch" => ["in", "inches", "\""],
  "centimeter" => ["cm", "centimeters", "centimetre", "centimetres"],

  # Count/Descriptive
  "piece" => ["pc", "pcs", "pieces"],
  "whole" => ["wholes"],
  "slice" => ["slices"],
  "clove" => ["cloves"],
  "head" => ["heads"],
  "bunch" => ["bunches"],
  "sprig" => ["sprigs"],
  "stalk" => ["stalks"],
  "leaf" => ["leaves"],
  "handful" => ["handfuls"],
  "pinch" => ["pinches"],
  "dash" => ["dashes"],
  "can" => ["cans", "tin", "tins"],
  "package" => ["pkg", "pkgs", "packages", "pack", "packs"],
  "container" => ["containers"],
  "jar" => ["jars"],
  "bottle" => ["bottles"],
  "box" => ["boxes"],
  "bag" => ["bags"],

  # Size descriptors (often used with produce)
  "small" => ["sm"],
  "medium" => ["med", "md"],
  "large" => ["lg"],
  "extra large" => ["xl", "x-large"]
}

measurement_units = {}
measurement_units_data.each do |unit_name, aliases|
  unit = MeasurementUnit.find_or_create_by!(name: unit_name)
  measurement_units[unit_name] = unit

  # Create aliases for this measurement unit
  aliases.each do |alias_name|
    MeasurementUnitAlias.find_or_create_by!(
      measurement_unit: unit,
      name: alias_name
    )
  end
end

# Create ingredients
puts "  Creating ingredients..."
ingredients_data = [
  { name: "Chicken Breast", category: "Proteins" },
  { name: "Ground Beef", category: "Proteins" },
  { name: "Salmon Fillet", category: "Proteins" },
  { name: "Tomatoes", category: "Produce" },
  { name: "Onions", category: "Produce" },
  { name: "Garlic", category: "Produce" },
  { name: "Bell Peppers", category: "Produce" },
  { name: "Carrots", category: "Produce" },
  { name: "Potatoes", category: "Produce" },
  { name: "Lettuce", category: "Produce" },
  { name: "Milk", category: "Dairy" },
  { name: "Cheddar Cheese", category: "Dairy" },
  { name: "Parmesan Cheese", category: "Dairy" },
  { name: "Butter", category: "Dairy" },
  { name: "Rice", category: "Pantry" },
  { name: "Pasta", category: "Pantry" },
  { name: "Olive Oil", category: "Pantry" },
  { name: "Salt", category: "Pantry" },
  { name: "Black Pepper", category: "Pantry" },
  { name: "Cumin", category: "Pantry" }
]

ingredients = {}
ingredients_data.each do |ing_data|
  category = ingredient_categories[ing_data[:category]]
  ingredients[ing_data[:name]] = Ingredient.find_or_create_by!(
    name: ing_data[:name],
    ingredient_category: category
  )
end

# Create test user
puts "  Creating user..."
users = []
user = User.find_or_create_by!(email: "joyce.clay@test.com") do |u|
  u.first_name = "Joyce"
  u.last_name = "Clay"
  u.password = "Test123!"
  u.admin = true
end
users << user

puts "  Creating recipes..."
recipes_data = [
  {
    title: "Classic Chicken Parmesan",
    description: "Crispy breaded chicken topped with marinara and melted cheese",
    prep_time: 20,
    cook_time: 30,
    servings: 4,
    ingredients: [
      { name: "Chicken Breast", quantity: "4", unit: "piece" },
      { name: "Parmesan Cheese", quantity: "1", unit: "cup" },
      { name: "Tomatoes", quantity: "2", unit: "cup" },
      { name: "Garlic", quantity: "3", unit: "clove" },
      { name: "Olive Oil", quantity: "2", unit: "tablespoon" }
    ]
  },
  {
    title: "Beef Tacos",
    description: "Seasoned ground beef tacos with fresh toppings",
    prep_time: 10,
    cook_time: 15,
    servings: 6,
    ingredients: [
      { name: "Ground Beef", quantity: "1", unit: "pound" },
      { name: "Onions", quantity: "1", unit: "medium" },
      { name: "Tomatoes", quantity: "2", unit: "medium" },
      { name: "Cheddar Cheese", quantity: "1", unit: "cup" },
      { name: "Lettuce", quantity: "1", unit: "head" },
      { name: "Cumin", quantity: "1", unit: "tablespoon" }
    ]
  },
  {
    title: "Garlic Butter Salmon",
    description: "Pan-seared salmon with garlic butter sauce",
    prep_time: 10,
    cook_time: 12,
    servings: 2,
    ingredients: [
      { name: "Salmon Fillet", quantity: "2", unit: "piece" },
      { name: "Butter", quantity: "3", unit: "tablespoon" },
      { name: "Garlic", quantity: "4", unit: "clove" },
      { name: "Salt", quantity: "1", unit: "teaspoon" },
      { name: "Black Pepper", quantity: "1/2", unit: "teaspoon" }
    ]
  },
  {
    title: "Vegetable Stir Fry",
    description: "Colorful vegetables in a savory sauce over rice",
    prep_time: 15,
    cook_time: 10,
    servings: 4,
    ingredients: [
      { name: "Bell Peppers", quantity: "2", unit: "medium" },
      { name: "Carrots", quantity: "2", unit: "medium" },
      { name: "Onions", quantity: "1", unit: "medium" },
      { name: "Garlic", quantity: "3", unit: "clove" },
      { name: "Rice", quantity: "2", unit: "cup" },
      { name: "Olive Oil", quantity: "2", unit: "tablespoon" }
    ]
  },
  {
    title: "Creamy Pasta Primavera",
    description: "Fresh vegetables tossed with pasta in a creamy sauce",
    prep_time: 15,
    cook_time: 20,
    servings: 6,
    ingredients: [
      { name: "Pasta", quantity: "1", unit: "pound" },
      { name: "Bell Peppers", quantity: "1", unit: "medium" },
      { name: "Tomatoes", quantity: "2", unit: "medium" },
      { name: "Garlic", quantity: "3", unit: "clove" },
      { name: "Milk", quantity: "1", unit: "cup" },
      { name: "Parmesan Cheese", quantity: "1/2", unit: "cup" },
      { name: "Butter", quantity: "2", unit: "tablespoon" }
    ]
  }
]

recipes = []
recipes_data.each do |recipe_data|
  recipe = Recipe.find_or_create_by!(name: recipe_data[:title]) do |r|
    r.description = recipe_data[:description]
    r.serving_size = recipe_data[:servings]
    r.duration_minutes = recipe_data[:prep_time] + recipe_data[:cook_time]
    r.difficulty_level = "easy"
  end

  # Add ingredients to recipe
  recipe_data[:ingredients].each do |ing_data|
    ingredient = ingredients[ing_data[:name]]
    measurement_unit = measurement_units[ing_data[:unit]]

    # Parse quantity string to numerator/denominator
    quantity_str = ing_data[:quantity]
    if quantity_str.include?("/")
      parts = quantity_str.split("/")
      numerator = parts[0].to_i
      denominator = parts[1].to_i
    else
      numerator = quantity_str.to_i
      denominator = 1
    end

    RecipeIngredient.find_or_create_by!(
      recipe: recipe,
      ingredient: ingredient
    ) do |ri|
      ri.numerator = numerator
      ri.denominator = denominator
      ri.measurement_unit = measurement_unit
    end
  end

  recipes << recipe
end

# Create user-owned recipes
puts "  Creating user-generated recipes..."
2.times do |i|
  user_recipe = Recipe.find_or_create_by!(name: "Joyce's Special Recipe #{i + 1}") do |r|
    r.description = "A family favorite passed down through generations"
    r.serving_size = 4
    r.duration_minutes = 45
    r.difficulty_level = "medium"
  end

  # Associate recipe with user
  UserRecipe.find_or_create_by!(user: user, recipe: user_recipe)
end

# Create favorites
puts "  Creating favorites..."
recipes.sample(3).each do |recipe|
  RecipeFavorite.find_or_create_by!(user: user, recipe: recipe)
end

# Create meal plan
puts "  Creating meal plans..."
meal_plan = MealPlan.find_or_create_by!(name: "Joyce's Weekly Meal Plan") do |mp|
  mp.description = "Meal plan for the week"
  mp.featured = false
end

# Associate meal plan with user
UserMealPlan.find_or_create_by!(user: user, meal_plan: meal_plan)

# Add recipes to meal plan
7.times do |day|
  date = Date.today + day.days
  recipe = recipes.sample
  MealPlanRecipe.find_or_create_by!(
    meal_plan: meal_plan,
    recipe: recipe,
    date: date
  ) do |mpr|
    mpr.day_sequence = day + 1
  end
end

# Create shopping lists
puts "  Creating shopping lists..."
shopping_list = ShoppingList.find_or_create_by!(
  user: user,
  name: "Weekly Shopping"
) do |sl|
  sl.current = true
end

# Add items to shopping list
ingredients.values.sample(8).each do |ingredient|
  quantity = rand(1..3)
  unit = measurement_units.values.sample
  item_name = "#{quantity} #{unit.name} #{ingredient.name}"

  ShoppingListItem.find_or_create_by!(
    shopping_list: shopping_list,
    name: item_name
  )
end

puts "✅ Seeding complete!"
puts "\n📊 Database Summary:"
puts "  User: #{User.count}"
puts "  Recipes: #{Recipe.count}"
puts "  User-Owned Recipes: #{UserRecipe.count}"
puts "  Ingredients: #{Ingredient.count}"
puts "  Ingredient Categories: #{IngredientCategory.count}"
puts "  Measurement Units: #{MeasurementUnit.count}"
puts "  Measurement Unit Aliases: #{MeasurementUnitAlias.count}"
puts "  Favorites: #{RecipeFavorite.count}"
puts "  Meal Plans: #{MealPlan.count}"
puts "  Meal Plan Recipes: #{MealPlanRecipe.count}"
puts "  Shopping Lists: #{ShoppingList.count}"
puts "  Shopping List Items: #{ShoppingListItem.count}"
puts "\n🔑 Test Credentials:"
puts "  Email: joyce.clay@test.com"
puts "  Password: Test123!"
