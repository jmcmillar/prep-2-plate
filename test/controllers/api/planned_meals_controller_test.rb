require "test_helper"

class Api::PlannedMealsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @headers = { "Authorization" => "Bearer #{@user.sessions.create!.token}" }
  end

  test "index returns the user's meals in the range, in order" do
    @user.planned_meals.create!(date: Date.new(2026, 10, 5), recipe: recipes(:two), position: 1)
    @user.planned_meals.create!(date: Date.new(2026, 10, 5), kind: "leftovers", position: 0)
    @user.planned_meals.create!(date: Date.new(2026, 10, 20), recipe: recipes(:two))
    users(:two).planned_meals.create!(date: Date.new(2026, 10, 5), recipe: recipes(:two))

    get api_planned_meals_url(format: :json), params: { start: "2026-10-04", end: "2026-10-10" }, headers: @headers

    assert_response :success
    meals = JSON.parse(response.body)["plannedMeals"]
    assert_equal [ [ "2026-10-05", "leftovers", nil ], [ "2026-10-05", "recipe", recipes(:two).id ] ],
      meals.map { |m| [ m["date"], m["kind"], m.dig("recipe", "id") ] }
    assert_equal recipes(:two).name, meals.last.dig("recipe", "name")
  end

  test "replace saves the range and returns it" do
    put replace_api_planned_meals_url(format: :json), params: {
      start: "2026-10-04", end: "2026-10-10",
      planned_meals: [ { date: "2026-10-06", recipe_id: recipes(:two).id }, { date: "2026-10-07", kind: "skip" } ]
    }, headers: @headers

    assert_response :success
    assert_equal [ "recipe", "skip" ], JSON.parse(response.body)["plannedMeals"].map { |m| m["kind"] }
    assert_equal 2, @user.planned_meals.count
  end

  test "replace with no meals clears the range" do
    @user.planned_meals.create!(date: Date.new(2026, 10, 6), recipe: recipes(:two))

    put replace_api_planned_meals_url(format: :json), params: { start: "2026-10-04", end: "2026-10-10" }, headers: @headers

    assert_response :success
    assert_equal 0, @user.planned_meals.count
  end

  test "replace rejects invalid meals" do
    put replace_api_planned_meals_url(format: :json), params: {
      start: "2026-10-04", end: "2026-10-10", planned_meals: [ { date: "2026-10-06", kind: "recipe" } ]
    }, headers: @headers

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].any?
  end

  test "bad dates are a 400" do
    get api_planned_meals_url(format: :json), params: { start: "next week", end: "2026-10-10" }, headers: @headers

    assert_response :bad_request
  end
end
