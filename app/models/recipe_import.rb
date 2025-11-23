class RecipeImport < ApplicationRecord
  has_many :recipes, class_name: "Recipe", foreign_key: "recipe_import_id"

  validates :url, presence: true, uniqueness: { case_sensitive: false }
  validates :url, https_url: true
end
