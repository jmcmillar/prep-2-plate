class Recipe < ApplicationRecord
  # enum difficulty_level: {
  #   easy: "easy",
  #   medium: "medium",
  #   hard: "hard"
  # }, _suffix: true
  has_rich_text :description
  has_one_attached :image
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipe_instructions, dependent: :destroy
  has_many :meal_plan_recipes, dependent: :destroy
  has_many :measurement_units, through: :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_meal_types, dependent: :destroy
  has_many :meal_types, through: :recipe_meal_types
  has_many :recipe_category_assignments, dependent: :destroy
  has_many :recipe_categories, through: :recipe_category_assignments
  has_many :recipe_favorites, dependent: :destroy
  has_one :user_recipe, dependent: :destroy

  scope :featured, -> { where(featured: true) }
end
