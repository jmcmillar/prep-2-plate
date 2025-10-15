class RecipeIngredient::FullNameDecorator < BaseDecorator

  def full_name
    [quantity, measurement_unit, ingredient_name].compact.join(' ')
  end

  def ingredient_name
    [@object.ingredient_name, notes].compact.join(" ")
  end

  def formatted_quantity
    [quantity, measurement_unit].compact.join(' ')
  end

  def notes
    @object.notes.present? ? "(#{@object.notes})" : nil
  end

  def quantity
    # return nil if whole_number_quantity.zero?
    return numerator if whole_number?
    if numerator < denominator
      formatted_fraction(numerator, denominator)
    else
      mixed_number_faction
    end
  end

  def whole_number?
    numerator % denominator == 0
  end

  def formatted_fraction(numerator, denominator)
    Rational(numerator, denominator)
  end

  def mixed_number_faction
    [whole_number_quantity, fraction_quantity].compact.join(' ')
  end

  def whole_number_quantity
    numerator / denominator
  end

  def fraction_quantity
    "#{(numerator % denominator)}/#{denominator}"
  end

  def measurement_unit
    measurement_unit_name.present? ? "#{measurement_unit_name}" : nil
  end
end
