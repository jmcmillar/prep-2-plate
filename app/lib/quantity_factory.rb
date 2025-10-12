class QuantityFactory
  def initialize(quantity)
    @quantity = quantity
  end

  def create
    if @quantity.include?(".")
      Conversions::DecimalToFraction.compute(@quantity)
    elsif @quantity.include?("/")
      Conversions::MixedToImproperFraction.compute(@quantity)
    else
      Conversions::WholeToFraction.compute(@quantity)
    end
  end
end
