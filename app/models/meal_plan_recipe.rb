class MealPlanRecipe < ApplicationRecord
  belongs_to :meal_plan
  belongs_to :recipe
  has_many :ingredients, through: :recipe

  delegate :name, to: :recipe, prefix: true
end
