require "test_helper"

class Api::RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @session = @user.sessions.create!
    @recipe = recipes(:one)
    @user.user_recipes.create!(recipe: @recipe)
    @headers = { 'Authorization' => "Bearer #{@session.token}" }
  end

  test "should get index" do
    get api_recipes_url(format: :json), headers: @headers
    assert_response :success
  end

  test "should show recipe" do
    get api_recipe_url(@recipe, format: :json), headers: @headers
    assert_response :success
  end

  test "should create recipe" do
    assert_difference('Recipe.count', 1) do
      post api_recipes_url(format: :json), params: { 
        recipe: { 
          title: "New Recipe",
          ingredients: ["1 cup flour", "2 eggs"],
          steps: ["Mix ingredients", "Bake"]
        }
      }, headers: @headers
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Recipe created successfully", json_response["message"]
    assert json_response["recipe"].present?
  end

  test "should not create recipe with invalid params" do
    assert_no_difference('Recipe.count') do
      post api_recipes_url(format: :json), params: { 
        recipe: { 
          title: "",
          ingredients: [],
          steps: []
        }
      }, headers: @headers
    end

    assert_response :unprocessable_entity
  end

  test "should update recipe" do
    patch api_recipe_url(@recipe, format: :json), params: { 
      recipe: { 
        title: "Updated Recipe",
        ingredients: ["3 cups flour", "4 eggs"],
        steps: ["Mix well", "Bake at 375°F"]
      }
    }, headers: @headers

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Recipe updated successfully", json_response["message"]
  end

  test "should keep existing title when empty title provided" do
    original_name = @recipe.name
    patch api_recipe_url(@recipe, format: :json), params: { 
      recipe: { 
        title: "",
        ingredients: ["flour"],
        steps: ["Mix"]
      }
    }, headers: @headers

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Recipe updated successfully", json_response["message"]
    @recipe.reload
    assert_equal original_name, @recipe.name
  end
end
