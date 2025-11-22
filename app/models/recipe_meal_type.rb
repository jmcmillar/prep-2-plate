class RecipeMealType < ApplicationRecord
  belongs_to :recipe
  belongs_to :meal_type

  validates :recipe_id, presence: true, uniqueness: { scope: :meal_type_id }
  validates :meal_type_id, presence: true
end
