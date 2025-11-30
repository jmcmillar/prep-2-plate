class IngredientCategory < ApplicationRecord
  has_many :ingredients, dependent: :nullify
end
