class Conversions::MixedToImproperFraction
  def initialize(value)
    @value = parse_value(value)
  end

  def self.compute(value)
    new(value).compute
  end

  def compute
    Rational((whole_number * fraction_part.denominator) + fraction_part.numerator, fraction_part.denominator)
  end

  private

  def parse_value(value)
    if value.is_a?(String)
      if value.include?(' ')
        whole, fraction = value.split(' ')
        whole.to_i + Rational(fraction)
      else
        Rational(value)
      end
    else
      value
    end
  end

  def whole_number
    @value.to_i
  end

  def fraction_part
    Rational(@value - whole_number)
  end
end
