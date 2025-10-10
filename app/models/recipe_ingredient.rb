class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  belongs_to :measurement_unit, optional: true
  delegate :name, to: :measurement_unit, prefix: true, allow_nil: true
  delegate :name, to: :ingredient, prefix: true

  def quantity
    return unless numerator && denominator
    numerator.to_f / denominator.to_f
  end
end
