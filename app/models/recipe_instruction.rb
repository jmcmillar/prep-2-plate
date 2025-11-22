class RecipeInstruction < ApplicationRecord
  belongs_to :recipe

  validates :recipe_id, presence: true
  validates :step_number, presence: true,
                          numericality: { only_integer: true, greater_than: 0 },
                          uniqueness: { scope: :recipe_id }
  validates :instruction, presence: true
end
