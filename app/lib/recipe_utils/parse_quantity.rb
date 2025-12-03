class RecipeUtils::ParseQuantity
  def initialize(quantity)
    @quantity = quantity
  end

  def to_value
    parts.reduce(0) { |sum, part|
      if includes_fraction?(part)
        Rational(sum) + convert_part(part)
      elsif part.include?(".")
        Rational(sum) + convert_decimal(part)
      else
        Rational(sum) + Rational(part.to_i)
      end
    }
  end

  private

  def parts
    @quantity.split(" ")
  end

  def includes_fraction?(part)
    part.include?("/")
  end

  def convert_part(part)
    Rational(part).to_r
  end

  def convert_decimal(decimal_string)
    # Convert decimal to float
    decimal = decimal_string.to_f

    # Extract whole and fractional parts
    whole = decimal.floor
    fractional = decimal - whole

    # Try to match common cooking fractions for the fractional part
    common_fractions = {
      0.125 => Rational(1, 8),
      0.25 => Rational(1, 4),
      0.33 => Rational(1, 3),
      0.375 => Rational(3, 8),
      0.5 => Rational(1, 2),
      0.625 => Rational(5, 8),
      0.67 => Rational(2, 3),
      0.75 => Rational(3, 4),
      0.875 => Rational(7, 8)
    }

    # Check if fractional part is close to a common fraction (within 0.01)
    fraction_match = nil
    common_fractions.each do |decimal_value, fraction|
      if (fractional - decimal_value).abs < 0.01
        fraction_match = fraction
        break
      end
    end

    # Build the final rational
    if fraction_match
      Rational(whole) + fraction_match
    else
      # For other decimals, round to nearest 1/16 to keep denominators reasonable
      # This prevents massive numerator/denominator values that exceed integer limits
      sixteenths = (decimal * 16).round
      Rational(sixteenths, 16)
    end
  end
end
