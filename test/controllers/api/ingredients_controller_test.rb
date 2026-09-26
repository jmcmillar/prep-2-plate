require "test_helper"

class Api::IngredientsControllerTest < ActionDispatch::IntegrationTest
  include MeasurementUnitHelper

  def setup
    create_parser_units
    @user = users(:one)
    @session = @user.sessions.create!
    @headers = { "Authorization" => "Bearer #{@session.token}" }
  end

  def test_suggests_ingredient_names_for_the_name_part_of_the_line
    get suggest_api_ingredients_url(format: :json), params: { q: "2 cups tomat" }, headers: @headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "tomat", json["fragment"]
    assert_equal [ "tomatoes" ], json["suggestions"].map { |s| s["name"] }
  end

  def test_ranks_prefix_matches_before_word_matches
    get suggest_api_ingredients_url(format: :json), params: { q: "bee" }, headers: @headers

    names = JSON.parse(response.body)["suggestions"].map { |s| s["name"] }
    assert_equal [ "beef steak", "ground beef" ], names.first(2)
  end

  def test_matches_misspellings
    get suggest_api_ingredients_url(format: :json), params: { q: "1 brocolli" }, headers: @headers

    names = JSON.parse(response.body)["suggestions"].map { |s| s["name"] }
    assert_includes names, "broccoli"
  end

  def test_returns_nothing_for_a_short_fragment_or_a_finished_name
    [ "2 cups f", "2 cups flour, sifted" ].each do |q|
      get suggest_api_ingredients_url(format: :json), params: { q: q }, headers: @headers

      assert_response :success
      assert_empty JSON.parse(response.body)["suggestions"], q
    end
  end

  def test_suggest_requires_authentication
    get suggest_api_ingredients_url(format: :json), params: { q: "tomat" }

    assert_response :unauthorized
  end
end
