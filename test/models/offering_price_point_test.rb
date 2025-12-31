require "test_helper"

class OfferingPricePointTest < ActiveSupport::TestCase
  def setup
    @price_point = offering_price_points(:grilled_chicken_2_servings)
  end

  # Validations
  def test_valid_price_point
    assert @price_point.valid?
  end

  def test_offering_required
    @price_point.offering = nil
    assert_not @price_point.valid?
    assert_includes @price_point.errors[:offering], "must exist"
  end

  def test_serving_size_required
    @price_point.serving_size = nil
    assert_not @price_point.valid?
    assert_includes @price_point.errors[:serving_size], "can't be blank"
  end

  def test_price_required
    @price_point.price = nil
    assert_not @price_point.valid?
    assert_includes @price_point.errors[:price], "can't be blank"
  end

  def test_serving_size_must_be_unique_per_offering
    duplicate = OfferingPricePoint.new(
      offering: @price_point.offering,
      serving_size: @price_point.serving_size,
      price: 29.99
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:serving_size], "has already been taken"
  end

  def test_same_serving_size_allowed_for_different_offerings
    other_offering = offerings(:protein_power_bowl)
    # Use a serving size that doesn't exist in protein_power_bowl yet
    new_price_point = OfferingPricePoint.new(
      offering: other_offering,
      serving_size: 12,
      price: 129.99
    )
    assert new_price_point.valid?
  end

  def test_price_must_be_greater_than_zero
    @price_point.price = 0
    assert_not @price_point.valid?
    assert_includes @price_point.errors[:price], "must be greater than 0"
  end

  def test_price_must_be_numeric
    @price_point.price = "not a number"
    assert_not @price_point.valid?
    assert_includes @price_point.errors[:price], "is not a number"
  end

  # Associations
  def test_belongs_to_offering
    assert_respond_to @price_point, :offering
    assert_kind_of Offering, @price_point.offering
  end

  # Data integrity
  def test_price_precision_and_scale
    @price_point.price = 99.99
    assert @price_point.save
    assert_equal BigDecimal("99.99"), @price_point.reload.price
  end

  def test_price_handles_large_values
    @price_point.price = 9999.99
    assert @price_point.save
    assert_equal BigDecimal("9999.99"), @price_point.reload.price
  end
end
