require "test_helper"

class UserRecipes::ProcessParamsTest < ActiveSupport::TestCase
  test "converts whole number quantity to numerator and denominator" do
    params = build_params(quantity: "2")
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_equal 2, ingredient[:numerator]
    assert_equal 1, ingredient[:denominator]
    assert_nil ingredient[:quantity]
  end

  test "converts decimal quantity to numerator and denominator" do
    params = build_params(quantity: "1.5")
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_equal 3, ingredient[:numerator]
    assert_equal 2, ingredient[:denominator]
    assert_nil ingredient[:quantity]
  end

  test "converts simple fraction quantity to numerator and denominator" do
    params = build_params(quantity: "1/2")
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_equal 1, ingredient[:numerator]
    assert_equal 2, ingredient[:denominator]
    assert_nil ingredient[:quantity]
  end

  test "converts mixed fraction quantity to numerator and denominator" do
    params = build_params(quantity: "1 1/2")
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_equal 3, ingredient[:numerator]
    assert_equal 2, ingredient[:denominator]
    assert_nil ingredient[:quantity]
  end

  test "processes multiple ingredients" do
    params = {
      recipe_attributes: {
        name: "Test Recipe",
        recipe_ingredients_attributes: {
          "0" => { ingredient_name: "flour", quantity: "2" },
          "1" => { ingredient_name: "sugar", quantity: "1/2" },
          "2" => { ingredient_name: "milk", quantity: "1.5" }
        }
      }
    }
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredients = result[:recipe_attributes][:recipe_ingredients_attributes]
    
    # First ingredient
    assert_equal 2, ingredients["0"][:numerator]
    assert_equal 1, ingredients["0"][:denominator]
    assert_nil ingredients["0"][:quantity]
    
    # Second ingredient
    assert_equal 1, ingredients["1"][:numerator]
    assert_equal 2, ingredients["1"][:denominator]
    assert_nil ingredients["1"][:quantity]
    
    # Third ingredient
    assert_equal 3, ingredients["2"][:numerator]
    assert_equal 2, ingredients["2"][:denominator]
    assert_nil ingredients["2"][:quantity]
  end

  test "skips ingredients without quantity" do
    params = build_params(quantity: nil)
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_nil ingredient[:numerator]
    assert_nil ingredient[:denominator]
    assert_nil ingredient[:quantity]
  end

  test "skips ingredients with blank quantity" do
    params = build_params(quantity: "")
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_nil ingredient[:numerator]
    assert_nil ingredient[:denominator]
    assert_equal "", ingredient[:quantity]
  end

  test "does not modify original params" do
    params = build_params(quantity: "1/2")
    original_params = params.deep_dup
    
    UserRecipes::ProcessParams.new(params).call
    
    assert_equal original_params, params
  end

  test "handles params without recipe_ingredients_attributes" do
    params = {
      recipe_attributes: {
        name: "Test Recipe",
        description: "A test recipe"
      }
    }
    
    result = UserRecipes::ProcessParams.new(params).call
    
    assert_equal "Test Recipe", result[:recipe_attributes][:name]
    assert_equal "A test recipe", result[:recipe_attributes][:description]
  end

  test "preserves other ingredient attributes" do
    params = {
      recipe_attributes: {
        recipe_ingredients_attributes: {
          "0" => {
            ingredient_id: 1,
            ingredient_name: "flour",
            measurement_unit_id: 2,
            quantity: "1/2",
            ingredient_notes: "sifted"
          }
        }
      }
    }
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_equal 1, ingredient[:ingredient_id]
    assert_equal "flour", ingredient[:ingredient_name]
    assert_equal 2, ingredient[:measurement_unit_id]
    assert_equal "sifted", ingredient[:ingredient_notes]
    assert_equal 1, ingredient[:numerator]
    assert_equal 2, ingredient[:denominator]
    assert_nil ingredient[:quantity]
  end

  test "handles ingredient marked for destruction" do
    params = {
      recipe_attributes: {
        recipe_ingredients_attributes: {
          "0" => {
            id: 1,
            ingredient_name: "flour",
            quantity: "1/2",
            _destroy: "1"
          }
        }
      }
    }
    
    result = UserRecipes::ProcessParams.new(params).call
    
    ingredient = result[:recipe_attributes][:recipe_ingredients_attributes]["0"]
    assert_equal "1", ingredient[:_destroy]
    assert_equal 1, ingredient[:numerator]
    assert_equal 2, ingredient[:denominator]
  end

  private

  def build_params(quantity:)
    {
      recipe_attributes: {
        name: "Test Recipe",
        recipe_ingredients_attributes: {
          "0" => {
            ingredient_name: "flour",
            quantity: quantity
          }
        }
      }
    }
  end
end
