require "test_helper"

# recipes(:one) belongs to users(:one) (see user_recipes.yml) and is assigned
# to recipe_categories(:one), so it is private to that user. users(:two) must
# not be able to read it or attach it to anything through the API.
class Api::RecipeVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @other = users(:two)
    @private_recipe = recipes(:one)
    @headers = { "Authorization" => "Bearer #{@other.sessions.create!.token}" }
  end

  test "owner can view their own recipe" do
    owner_headers = { "Authorization" => "Bearer #{@owner.sessions.create!.token}" }

    get api_recipe_url(@private_recipe, format: :json), headers: owner_headers

    assert_response :success
  end

  test "another user cannot view a private recipe" do
    get api_recipe_url(@private_recipe, format: :json), headers: @headers

    assert_response :not_found
  end

  test "recipe index excludes other users' recipes" do
    get api_recipes_url(format: :json), headers: @headers

    ids = JSON.parse(response.body)["recipes"].map { |r| r["id"] }
    assert_not_includes ids, @private_recipe.id
    assert_includes ids, recipes(:two).id
  end

  test "category index excludes other users' recipes" do
    get api_recipe_categories_url(format: :json), headers: @headers

    ids = JSON.parse(response.body)["recipeCategories"].flat_map { |c| c["recipes"].map { |r| r["id"] } }
    assert_not_includes ids, @private_recipe.id
  end

  test "category show excludes other users' recipes" do
    get api_recipe_category_url(recipe_categories(:one), format: :json), headers: @headers

    assert_response :success
    ids = JSON.parse(response.body)["recipes"].map { |r| r["id"] }
    assert_not_includes ids, @private_recipe.id
  end

  test "cannot favorite another user's recipe" do
    assert_no_difference "RecipeFavorite.count" do
      post api_recipe_favorites_url(format: :json), params: { recipe_id: @private_recipe.id }, headers: @headers
    end

    assert_response :not_found
  end

  test "cannot add another user's recipe to a saved meal plan" do
    assert_no_difference "MealPlan.count" do
      post api_user_meal_plans_url(format: :json),
        params: { user_meal_plans: { "2026-10-05" => { recipeIds: [ @private_recipe.id ] } } },
        headers: @headers
    end

    assert_response :unprocessable_entity
  end

  test "cannot create a meal plan with another user's recipe" do
    assert_no_difference "MealPlan.count" do
      post api_meal_plans_url(format: :json),
        params: { name: "Sneaky", meal_plan_recipes_attributes: [ { recipe_id: @private_recipe.id, date: "2026-10-05" } ] },
        headers: @headers
    end

    assert_response :not_found
  end
end
