class Recipe < ApplicationRecord
  # enum difficulty_level: {
  #   easy: "easy",
  #   medium: "medium",
  #   hard: "hard"
  has_rich_text :description
  has_one_attached :image
  
  belongs_to :recipe_import, optional: true
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

  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true

  scope :imported, -> { where.not(recipe_import_id: nil) }

  scope :filtered_by_recipe_categories, -> (category_ids) {
    return all if category_ids.blank?
    includes(:recipe_categories).where(recipe_categories: { id: category_ids })
  }

  scope :filtered_by_meal_types, -> (meal_type_ids) {
    return all if meal_type_ids.blank?
    includes(:meal_types).where(meal_types: { id: meal_type_ids })
  }

  scope :filtered_by_recipe_category_ids, -> (category_ids) {
    return all if category_ids.blank?
    joins(:recipe_category_assignments).where(recipe_category_assignments: { recipe_category_id: category_ids })
  }

  scope :filtered_by_duration, -> (duration) {
    return all if duration.blank?
    where("recipes.duration_minutes <= ?", duration)
  }

  scope :featured, -> {
    where(featured: true)
  }

  def self.difficulty_levels
    { easy: "easy", medium: "medium", hard: "hard" }
  end

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end
