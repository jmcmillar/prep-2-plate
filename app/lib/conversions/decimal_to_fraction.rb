class Conversions::DecimalToFraction
  def initialize(value)
    @value = value.to_f
  end

  def self.compute(value)
    new(value).compute
  end

  def compute
    return 0 if @value.negative?
    Rational(@value).rationalize(tolerance = 0.01)
  end
end
