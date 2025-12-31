require "test_helper"

class OfferingTest < ActiveSupport::TestCase
  def setup
    @offering = offerings(:grilled_chicken_veggies)
  end

  # Validations
  def test_valid_offering
    assert @offering.valid?
  end

  def test_name_required
    @offering.name = nil
    assert_not @offering.valid?
    assert_includes @offering.errors[:name], "can't be blank"
  end

  def test_vendor_required
    @offering.vendor = nil
    assert_not @offering.valid?
    assert_includes @offering.errors[:vendor], "must exist"
  end

  def test_base_serving_size_defaults_to_2
    new_offering = Offering.new(
      vendor: vendors(:healthy_meal_co),
      name: "Test Offering"
    )
    assert_equal 2, new_offering.base_serving_size
  end

  def test_featured_defaults_to_false
    new_offering = Offering.new(
      vendor: vendors(:healthy_meal_co),
      name: "Test Offering"
    )
    assert_equal false, new_offering.featured
  end

  # Associations
  def test_belongs_to_vendor
    assert_respond_to @offering, :vendor
    assert_kind_of Vendor, @offering.vendor
  end

  def test_has_many_offering_ingredients
    assert_respond_to @offering, :offering_ingredients
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @offering.offering_ingredients
  end

  def test_destroying_offering_destroys_ingredients
    ingredient = @offering.offering_ingredients.create!(
      ingredient: ingredients(:chicken_breast),
      numerator: 1,
      denominator: 1
    )
    ingredient_count = @offering.offering_ingredients.count
    assert_difference "OfferingIngredient.count", -ingredient_count do
      @offering.destroy
    end
  end

  def test_has_many_offering_price_points
    assert_respond_to @offering, :offering_price_points
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @offering.offering_price_points
  end

  def test_destroying_offering_destroys_price_points
    price_point = @offering.offering_price_points.create!(
      serving_size: 12,
      price: 119.99
    )
    price_point_count = @offering.offering_price_points.count
    assert_difference "OfferingPricePoint.count", -price_point_count do
      @offering.destroy
    end
  end

  def test_has_many_meal_types
    assert_respond_to @offering, :meal_types
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @offering.meal_types
  end

  def test_has_rich_text_description
    assert_respond_to @offering, :description
  end

  def test_has_one_attached_image
    assert_respond_to @offering, :image
  end

  # Nested Attributes
  def test_accepts_nested_attributes_for_offering_ingredients
    assert Offering.nested_attributes_options.key?(:offering_ingredients)
  end

  def test_accepts_nested_attributes_for_offering_price_points
    assert Offering.nested_attributes_options.key?(:offering_price_points)
  end

  # Instance Methods
  def test_price_for_servings_returns_correct_price
    price_point = @offering.offering_price_points.find_by(serving_size: 2)
    assert_equal price_point.price, @offering.price_for_servings(2)
  end

  def test_price_for_servings_returns_nil_for_unavailable_size
    assert_nil @offering.price_for_servings(12)
  end

  def test_available_serving_sizes_returns_ordered_array
    sizes = @offering.available_serving_sizes
    assert_kind_of Array, sizes
    assert_equal sizes.sort, sizes
  end

  # Scopes
  def test_featured_scope
    featured_offerings = Offering.featured
    assert_includes featured_offerings, offerings(:grilled_chicken_veggies)
    assert_not_includes featured_offerings, offerings(:taco_night_kit)
  end

  # Ransackable attributes
  def test_ransackable_attributes
    assert_includes Offering.ransackable_attributes, "name"
    assert_includes Offering.ransackable_attributes, "featured"
    assert_includes Offering.ransackable_attributes, "base_serving_size"
  end

  def test_ransackable_associations
    assert_includes Offering.ransackable_associations, "vendor"
    assert_includes Offering.ransackable_associations, "meal_types"
  end
end
