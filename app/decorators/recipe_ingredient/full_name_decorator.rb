class RecipeIngredient::FullNameDecorator < BaseDecorator

  def full_name
    [formatted_quantity, ingredient_name].compact.join(' ')
  end

  def ingredient_name
    [@object.ingredient_name, notes].compact.join(" ")
  end

  def formatted_quantity
    return nil if quantity_value.nil? || quantity_value.zero?
    [quantity, pluralized_measurement_unit].compact.join(' ')
  end

  def notes
    @object.notes.present? ? "(#{@object.notes})" : nil
  end

  def quantity
    return nil if quantity_value.nil? || quantity_value.zero?
    
    if whole_number?
      whole_number_quantity
    elsif numerator < denominator
      formatted_fraction(numerator, denominator)
    else
      mixed_number_fraction
    end
  end

  def quantity_value
    @quantity_value ||= Rational(numerator, denominator)
  end

  def whole_number?
    numerator % denominator == 0
  end

  def formatted_fraction(numerator, denominator)
    Rational(numerator, denominator).to_s
  end

  def mixed_number_fraction  # Fixed typo: was "faction"
    whole_part = numerator / denominator
    remainder = numerator % denominator
    
    return whole_part if remainder.zero?
    "#{whole_part} #{remainder}/#{denominator}"
  end

  def whole_number_quantity
    numerator / denominator
  end

  def fraction_quantity
    "#{(numerator % denominator)}/#{denominator}"
  end

  def pluralized_measurement_unit
    return nil unless measurement_unit_name.present?
    
    if quantity_value > 1
      measurement_unit_name.pluralize
    else
      measurement_unit_name.singularize
    end
  end

  def measurement_unit
    measurement_unit_name.present? ? "#{measurement_unit_name}" : nil
  end
end
