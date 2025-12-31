class Offering::PricingTierComponent < ApplicationComponent
  def initialize(price_points:, selected_size: nil)
    @price_points = price_points
    @selected_size = selected_size || price_points.first&.serving_size
  end

  def price_points
    @price_points.sort_by(&:serving_size)
  end

  def selected?(price_point)
    price_point.serving_size == @selected_size
  end

  def price_per_serving(price_point)
    price_point.price / price_point.serving_size
  end
end
