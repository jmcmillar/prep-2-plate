class MealPlan < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :meal_plan_recipes, dependent: :destroy
  has_many :recipes, through: :meal_plan_recipes
  has_many :ingredients, through: :recipes
  has_many :recipe_ingredients, through: :recipes

  accepts_nested_attributes_for :meal_plan_recipes

  scope :featured, -> {
    where(featured: true)
  }
end
