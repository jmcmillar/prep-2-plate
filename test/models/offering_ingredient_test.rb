require "test_helper"

class OfferingIngredientTest < ActiveSupport::TestCase
  def setup
    @offering_ingredient = offering_ingredients(:grilled_chicken_ingredient_1)
  end

  # Validations
  def test_valid_offering_ingredient
    assert @offering_ingredient.valid?
  end

  def test_offering_required
    @offering_ingredient.offering = nil
    assert_not @offering_ingredient.valid?
    assert_includes @offering_ingredient.errors[:offering], "must exist"
  end

  # Associations
  def test_belongs_to_offering
    assert_respond_to @offering_ingredient, :offering
    assert_kind_of Offering, @offering_ingredient.offering
  end

  def test_belongs_to_ingredient
    assert_respond_to @offering_ingredient, :ingredient
    assert_kind_of Ingredient, @offering_ingredient.ingredient
  end

  def test_belongs_to_measurement_unit_optional
    assert_respond_to @offering_ingredient, :measurement_unit
    @offering_ingredient.measurement_unit = nil
    assert @offering_ingredient.valid?
  end

  # Fractional Quantity System
  def test_quantity_value_returns_whole_number
    @offering_ingredient.numerator = 2
    @offering_ingredient.denominator = 1
    assert_equal "2", @offering_ingredient.quantity_value
  end

  def test_quantity_value_returns_simple_fraction
    @offering_ingredient.numerator = 1
    @offering_ingredient.denominator = 2
    assert_equal "1/2", @offering_ingredient.quantity_value
  end

  def test_quantity_value_returns_mixed_number
    @offering_ingredient.numerator = 5
    @offering_ingredient.denominator = 2
    assert_equal "2 1/2", @offering_ingredient.quantity_value
  end

  def test_quantity_value_returns_nil_when_no_quantity
    @offering_ingredient.numerator = nil
    @offering_ingredient.denominator = nil
    assert_nil @offering_ingredient.quantity_value
  end

  def test_quantity_method_returns_rational
    @offering_ingredient.numerator = 3
    @offering_ingredient.denominator = 4
    assert_equal Rational(3, 4), @offering_ingredient.quantity
  end

  # Virtual Column
  def test_quantity_virtual_column_calculation
    @offering_ingredient.numerator = 1
    @offering_ingredient.denominator = 2
    @offering_ingredient.save!
    @offering_ingredient.reload
    assert_equal 0.5, @offering_ingredient.quantity
  end

  # Ingredient Auto-Creation
  def test_find_or_create_ingredient_creates_new_ingredient
    new_offering_ingredient = OfferingIngredient.new(
      offering: offerings(:grilled_chicken_veggies),
      ingredient_name: "New Ingredient",
      numerator: 1,
      denominator: 1
    )

    assert_difference "Ingredient.count", 1 do
      new_offering_ingredient.save!
    end

    assert_not_nil new_offering_ingredient.ingredient
    assert_equal "new ingredient", new_offering_ingredient.ingredient.name
  end

  def test_find_or_create_ingredient_finds_existing_ingredient
    existing_ingredient = ingredients(:chicken_breast)
    new_offering_ingredient = OfferingIngredient.new(
      offering: offerings(:grilled_chicken_veggies),
      ingredient_name: existing_ingredient.name,
      packaging_form: existing_ingredient.packaging_form,
      preparation_style: existing_ingredient.preparation_style,
      numerator: 1,
      denominator: 1
    )

    assert_no_difference "Ingredient.count" do
      new_offering_ingredient.save!
    end

    assert_equal existing_ingredient, new_offering_ingredient.ingredient
  end

  def test_ingredient_name_writer
    @offering_ingredient.ingredient_name = "Test Ingredient"
    assert_equal "Test Ingredient", @offering_ingredient.instance_variable_get(:@ingredient_name)
  end

  def test_packaging_form_writer
    @offering_ingredient.packaging_form = "fresh"
    assert_equal "fresh", @offering_ingredient.instance_variable_get(:@packaging_form)
  end

  def test_preparation_style_writer
    @offering_ingredient.preparation_style = "diced"
    assert_equal "diced", @offering_ingredient.instance_variable_get(:@preparation_style)
  end

  # Edge Cases
  def test_handles_zero_denominator_gracefully
    @offering_ingredient.numerator = 1
    @offering_ingredient.denominator = 0
    # Virtual column calculation should handle this without error
    assert @offering_ingredient.save
  end

  def test_handles_negative_quantities
    @offering_ingredient.numerator = -1
    @offering_ingredient.denominator = 2
    assert @offering_ingredient.save
    assert_equal "-1/2", @offering_ingredient.quantity_value
  end
end
