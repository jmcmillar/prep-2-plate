require "test_helper"

class Admin::UserRecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email, password: "password" }
  end

  test "should get index" do
    get admin_user_user_recipes_url(users(:one))
    assert_response :success
  end

  test "should get edit" do
    recipe = Recipe.create!(name: "Existing Recipe")
    ur = UserRecipe.create!(user: @user, recipe: recipe)

    get edit_admin_user_recipe_url(ur)
    assert_response :success
  end

  test "should update user_recipe" do
    recipe = Recipe.create!(name: "Existing Recipe")
    ur = UserRecipe.create!(user: @user, recipe: recipe)

    patch admin_user_recipe_url(ur), params: {
      user_recipe: {
        recipe_attributes: {
          id: recipe.id,
          name: "Updated Recipe"
        }
      }
    }

    assert_redirected_to admin_user_recipe_url(ur)
    ur.reload
    assert_equal "Updated Recipe", ur.recipe.name
  end

  test "should destroy user_recipe" do
    recipe = Recipe.create!(name: "To Delete")
    ur = UserRecipe.create!(user: @user, recipe: recipe)

    assert_difference('UserRecipe.count', -1) do
      delete admin_user_recipe_url(ur), as: :turbo_stream
    end

    assert_response :success
  end
end
