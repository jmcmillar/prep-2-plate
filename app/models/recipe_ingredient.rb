class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient, optional: true
  belongs_to :measurement_unit, optional: true

  attr_writer :ingredient_name, :packaging_form, :preparation_style

  delegate :name, to: :measurement_unit, prefix: true, allow_nil: true
  delegate :name, :display_name, to: :ingredient, prefix: true, allow_nil: true
  delegate :packaging_form, :preparation_style, to: :ingredient, prefix: true, allow_nil: true
  delegate :packaging_form, :preparation_style, to: :ingredient, allow_nil: true
  
  before_validation :find_or_create_ingredient
  validates :ingredient, presence: true, unless: -> { marked_for_destruction? }

  def ingredient_name
    @ingredient_name || ingredient&.name
  end

  def quantity
    return unless numerator && denominator
    numerator.to_f / denominator.to_f
  end

  def quantity_value
    return nil unless numerator && denominator
    
    if numerator % denominator == 0
      # Whole number
      (numerator / denominator).to_s
    elsif numerator < denominator
      # Proper fraction
      "#{numerator}/#{denominator}"
    else
      # Mixed number
      whole = numerator / denominator
      remainder = numerator % denominator
      "#{whole} #{remainder}/#{denominator}"
    end
  end

  private

  def find_or_create_ingredient
    # If ingredient_id is already set, use it
    return if ingredient_id.present?

    # If ingredient_name is provided, find or create the ingredient
    if @ingredient_name.present? && @ingredient_name.strip.present?
      self.ingredient = Ingredient.find_or_create_by!(
        name: @ingredient_name.strip.downcase,
        packaging_form: @packaging_form,
        preparation_style: @preparation_style
      )
    end
  end
end
