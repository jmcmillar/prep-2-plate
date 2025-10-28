class UserRecipe < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  has_many :meal_types, through: :recipe
  has_many :recipe_categories, through: :recipe

  accepts_nested_attributes_for :recipe, allow_destroy: true
  delegate :name, :image, :description, :serving_size, :duration_minutes, :difficulty_level,
           :recipe_ingredients, :recipe_instructions, to: :recipe

  def self.ransackable_associations(auth_object = nil)
    ["recipe"]
  end

  def self.ransackable_attributes(auth_object = nil)
    []
  end
end
