class RecipeImport < ApplicationRecord
  has_many :recipes, class_name: "Recipe", foreign_key: "recipe_import_id"
  validates :url, presence: true, uniqueness: { case_sensitive: false }
  validates_format_of :url, :with => /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?\Z/i
end
