require "test_helper"

class Admin::IngredientCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email, password: "password" }
    @ingredient_category = IngredientCategory.create!(name: "Vegetables")
  end

  test "should get index" do
    get admin_ingredient_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_ingredient_category_url
    assert_response :success
  end

  test "should create ingredient_category" do
    assert_difference('IngredientCategory.count', 1) do
      post admin_ingredient_categories_url, params: {
        ingredient_category: {
          name: "Fruits"
        }
      }
    end

    assert_redirected_to admin_ingredient_categories_url
  end

  test "should get edit" do
    get edit_admin_ingredient_category_url(@ingredient_category)
    assert_response :success
  end

  test "should update ingredient_category" do
    patch admin_ingredient_category_url(@ingredient_category), params: {
      ingredient_category: {
        name: "Updated Category"
      }
    }

    assert_redirected_to admin_ingredient_categories_url
    @ingredient_category.reload
    assert_equal "Updated Category", @ingredient_category.name
  end

  test "should destroy ingredient_category" do
    assert_difference('IngredientCategory.count', -1) do
      delete admin_ingredient_category_url(@ingredient_category), as: :turbo_stream
    end

    assert_response :success
  end
end
