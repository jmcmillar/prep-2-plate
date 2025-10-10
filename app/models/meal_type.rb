class MealType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :recipe_meal_types, dependent: :destroy
  has_many :recipes, through: :recipe_meal_types
end
