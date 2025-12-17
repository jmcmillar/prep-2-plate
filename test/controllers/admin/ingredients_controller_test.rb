require "test_helper"

class Admin::IngredientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
    @ingredient = Ingredient.create!(name: "test ingredient")
    @ingredient_category = ingredient_categories(:one)
  end

  test "should get index" do
    get admin_ingredients_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_ingredient_url
    assert_response :success
  end

  test "should create ingredient" do
    assert_difference("Ingredient.count", 1) do
      post admin_ingredients_url, params: {
        ingredient: {
          name: "New Ingredient"
        }
      }
    end

    assert_redirected_to admin_ingredients_url
    assert_equal "Ingredient was successfully created.", flash[:notice]
  end

  test "should create ingredient with category" do
    assert_difference("Ingredient.count", 1) do
      post admin_ingredients_url, params: {
        ingredient: {
          name: "Categorized Ingredient",
          ingredient_category_id: @ingredient_category.id
        }
      }
    end

    assert_redirected_to admin_ingredients_url
    ingredient = Ingredient.find_by(name: "categorized ingredient")
    assert_equal @ingredient_category.id, ingredient.ingredient_category_id
  end

  test "should not create ingredient with invalid params" do
    assert_no_difference("Ingredient.count") do
      post admin_ingredients_url, params: {
        ingredient: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_admin_ingredient_url(@ingredient)
    assert_response :success
  end

  test "should update ingredient" do
    patch admin_ingredient_url(@ingredient), params: {
      ingredient: {
        name: "Updated Ingredient"
      }
    }

    assert_redirected_to admin_ingredients_url
    @ingredient.reload
    assert_equal "updated ingredient", @ingredient.name
    assert_equal "Ingredient was successfully updated.", flash[:notice]
  end

  test "should update ingredient category" do
    patch admin_ingredient_url(@ingredient), params: {
      ingredient: {
        name: @ingredient.name,
        ingredient_category_id: @ingredient_category.id
      }
    }

    assert_redirected_to admin_ingredients_url
    @ingredient.reload
    assert_equal @ingredient_category.id, @ingredient.ingredient_category_id
  end

  test "should destroy ingredient" do
    assert_difference("Ingredient.count", -1) do
      delete admin_ingredient_url(@ingredient), as: :turbo_stream
    end

    assert_response :success
  end

  test "should not destroy ingredient with associated recipe ingredients" do
    recipe = recipes(:one)
    RecipeIngredient.create!(
      recipe: recipe,
      ingredient: @ingredient,
      numerator: 1,
      denominator: 1
    )

    assert_no_difference("Ingredient.count") do
      delete admin_ingredient_url(@ingredient), as: :turbo_stream
    end

    assert_response :success
  end
end
