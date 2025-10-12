class Conversions::WholeToFraction
  def initialize(value)
    @value = value.to_i
  end

  def self.compute(value)
    new(value).compute
  end

  def compute
    Rational(@value, 1)
  end
end
