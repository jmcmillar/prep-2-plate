require "test_helper"

class Api::RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @session = @user.sessions.create!
    @recipe = recipes(:one)
    @user.user_recipes.find_or_create_by!(recipe: @recipe)
    @headers = { 'Authorization' => "Bearer #{@session.token}" }
  end

  test "should get index" do
    get api_recipes_url(format: :json), headers: @headers
    assert_response :success
  end

  def test_suggests_recipes_matching_the_query_prefix_matches_first
    Recipe.create!(name: "Chicken Tacos")
    Recipe.create!(name: "Easy Chicken Parmesan")

    get suggest_api_recipes_url(format: :json), params: { q: "chi" }, headers: @headers

    assert_response :success
    suggestion = JSON.parse(response.body)["suggestions"].first
    assert_equal "Chicken Tacos", suggestion["name"]
    assert suggestion["imageUrl"].present?
    assert_equal [ "Chicken Tacos", "Easy Chicken Parmesan" ],
      JSON.parse(response.body)["suggestions"].map { |s| s["name"] }
  end

  def test_suggests_recipes_for_misspelled_queries
    Recipe.create!(name: "Easy Chicken Parmesan")

    get suggest_api_recipes_url(format: :json), params: { q: "chiken" }, headers: @headers

    assert_equal [ "Easy Chicken Parmesan" ], JSON.parse(response.body)["suggestions"].map { |s| s["name"] }
  end

  def test_suggests_the_users_own_recipes_but_not_other_users_recipes
    other_recipe = Recipe.create!(name: "Secret Family Recipe")
    users(:two).user_recipes.create!(recipe: other_recipe)
    own_recipe = Recipe.create!(name: "Secret Sauce")
    @user.user_recipes.create!(recipe: own_recipe)

    get suggest_api_recipes_url(format: :json), params: { q: "secret" }, headers: @headers

    assert_equal [ "Secret Sauce" ], JSON.parse(response.body)["suggestions"].map { |s| s["name"] }
  end

  def test_returns_no_suggestions_for_queries_shorter_than_two_characters
    get suggest_api_recipes_url(format: :json), params: { q: "r" }, headers: @headers

    assert_response :success
    assert_empty JSON.parse(response.body)["suggestions"]
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

  test "show includes the source url of an imported recipe" do
    get api_recipe_url(@recipe, format: :json), headers: @headers

    assert_response :success
    assert_equal recipe_imports(:one).url, JSON.parse(response.body)["sourceUrl"]
  end

  test "create assigns the chosen categories and ignores unknown ids" do
    post api_recipes_url(format: :json), params: {
      recipe: { title: "Categorized", ingredients: [ "1 cup flour" ], recipe_category_ids: [ recipe_categories(:two).id, 0 ] }
    }, headers: @headers

    assert_response :created
    assert_equal [ recipe_categories(:two) ], Recipe.find_by!(name: "Categorized").recipe_categories.to_a
  end

  test "update replaces categories" do
    patch api_recipe_url(@recipe, format: :json), params: {
      recipe: { recipe_category_ids: [ recipe_categories(:two).id ] }
    }, headers: @headers

    assert_response :success
    assert_equal [ recipe_categories(:two) ], @recipe.reload.recipe_categories.to_a
  end

  test "update without category ids keeps existing categories" do
    patch api_recipe_url(@recipe, format: :json), params: { recipe: { title: "Renamed" } }, headers: @headers

    assert_response :success
    assert_equal [ recipe_categories(:one) ], @recipe.reload.recipe_categories.to_a
  end

  test "update with a blank category id clears categories" do
    patch api_recipe_url(@recipe, format: :json), params: { recipe: { recipe_category_ids: [ "" ] } }, headers: @headers

    assert_response :success
    assert_empty @recipe.reload.recipe_categories
  end

  test "show includes category ids" do
    get api_recipe_url(@recipe, format: :json), headers: @headers

    assert_equal [ recipe_categories(:one).id ], JSON.parse(response.body)["categoryIds"]
  end
end
