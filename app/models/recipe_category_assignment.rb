class RecipeCategoryAssignment < ApplicationRecord
  belongs_to :recipe
  belongs_to :recipe_category

  validates :recipe_id, presence: true, uniqueness: { scope: :recipe_category_id }
  validates :recipe_category_id, presence: true
end
