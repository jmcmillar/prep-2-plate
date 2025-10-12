class QuantityMultiplierDecorator < BaseDecorator
  def initialize(object, serving_size)
    super
    @serving_size = serving_size.to_i
  end

  def quantity
    return default_fraction if default_serving_size == @serving_size
    default_fraction * @serving_size / default_serving_size
  end

  def denominator
    quantity.denominator
  end

  def numerator
    quantity.numerator
  end

  def default_fraction
    Rational(@object.numerator, @object.denominator)
  end

  def default_serving_size
    @object.recipe.serving_size || 4
  end
end
