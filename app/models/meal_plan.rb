class MealPlan < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :meal_plan_recipes, dependent: :destroy
  has_many :recipes, through: :meal_plan_recipes
  has_many :ingredients, through: :recipes
  has_many :recipe_ingredients, through: :recipes
  has_many :user_meal_plans, dependent: :destroy

  accepts_nested_attributes_for :meal_plan_recipes

  scope :featured, -> {
    where(featured: true)
  }

  scope :non_user_associated, -> {
    left_joins(:user_meal_plans).where(user_meal_plans: { id: nil })
  }

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end
