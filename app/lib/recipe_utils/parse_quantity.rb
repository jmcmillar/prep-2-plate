class RecipeUtils::ParseQuantity
  def initialize(quantity)
    @quantity = quantity
  end

  def to_value
    parts.reduce(0) { |sum, part| 
      if includes_fraction?(part)
        Rational(sum) + convert_part(part)
      else
        Rational(sum) + Rational(part)
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
end
