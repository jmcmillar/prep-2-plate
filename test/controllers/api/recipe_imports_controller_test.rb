require "test_helper"

class Api::RecipeImportsControllerTest < ActionDispatch::IntegrationTest
  PageResponse = Struct.new(:body, :headers)

  def setup
    @user = users(:one)
    @headers = { "Authorization" => "Bearer #{@user.sessions.create!.token}" }
  end

  def test_create_imports_recipe_with_parsed_ingredients
    with_page("wprm_graph.html") do
      assert_difference([ "Recipe.count", "UserRecipe.count", "RecipeImport.count" ], 1) do
        post_import("https://example.com/lemon-bars")
      end
    end

    assert_response :created
    recipe = Recipe.order(:created_at).last
    assert_equal "Grandma's Lemon Bars", recipe.name
    assert_equal 16, recipe.serving_size
    assert_equal 55, recipe.duration_minutes
    assert_equal @user, recipe.user_recipe.user
    assert_equal [ "all-purpose flour", "sugar", "large egg" ], recipe.recipe_ingredients.map(&:ingredient_name)
    assert_equal [ 3, 2 ], [ recipe.recipe_ingredients.first.numerator, recipe.recipe_ingredients.first.denominator ]
  end

  def test_create_returns_422_when_page_has_no_recipe
    with_page_body("<html><head><title>Nope</title></head></html>") do
      assert_no_difference("Recipe.count") { post_import("https://example.com/not-a-recipe") }
    end

    assert_response :unprocessable_entity
    assert_equal [ Api::RecipeImports::NewFacade::NOT_FOUND_ERROR ], response.parsed_body["errors"]
  end

  def test_create_returns_422_for_private_urls
    post_import("http://127.0.0.1/admin")

    assert_response :unprocessable_entity
    assert_match "private", response.parsed_body["errors"].first
  end

  def test_create_returns_422_when_fetch_fails
    Import::SafeFetch.stub(:get, ->(*) { raise Import::SafeFetch::FetchError, "returned HTTP 403" }) do
      post_import("https://example.com/blocked")
    end

    assert_response :unprocessable_entity
    assert_match "403", response.parsed_body["errors"].first
  end

  def test_show_previews_recipe_with_duration_fallback
    with_page("wprm_graph.html") do
      get api_recipe_imports_url(format: :json), params: { url: "https://example.com/lemon-bars" }, headers: @headers
    end

    assert_response :success
    assert_equal "Grandma's Lemon Bars", response.parsed_body["name"]
    assert_equal 55, response.parsed_body["duration"]
  end

  private

  def post_import(url)
    post api_recipe_imports_url(format: :json), params: { recipe_import: { url: url } }, headers: @headers
  end

  def with_page(fixture, &block)
    with_page_body(file_fixture("recipe_pages/#{fixture}").read, &block)
  end

  def with_page_body(body, &block)
    Import::SafeFetch.stub(:get, PageResponse.new(body, {}), &block)
  end
end
