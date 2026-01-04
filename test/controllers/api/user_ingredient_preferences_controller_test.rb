require "test_helper"

class Api::UserIngredientPreferencesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @session = sessions(:one)
    @ingredient = ingredients(:one)
  end

  def test_index_returns_camelCase_keys
    # Create a preference
    @user.user_ingredient_preferences.create!(
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Highland"
    )

    get api_user_ingredient_preferences_url,
        headers: auth_headers(@session.token),
        as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert json.is_a?(Array), "Should return an array"

    if json.any?
      preference = json.first
      assert preference.key?("id"), "Should include id"
      assert preference.key?("userId"), "Should include userId (camelCase)"
      assert preference.key?("ingredient"), "Should include ingredient"
      assert preference.key?("packagingForm"), "Should include packagingForm (camelCase)"
      assert preference.key?("preparationStyle"), "Should include preparationStyle (camelCase)"
      assert preference.key?("preferredBrand"), "Should include preferredBrand (camelCase)"
      assert preference.key?("usageCount"), "Should include usageCount (camelCase)"
      assert preference.key?("lastUsedAt"), "Should include lastUsedAt (camelCase)"
      assert preference.key?("displayContext"), "Should include displayContext (camelCase)"
      assert preference.key?("createdAt"), "Should include createdAt (camelCase)"
      assert preference.key?("updatedAt"), "Should include updatedAt (camelCase)"
    end
  end

  def test_show_returns_camelCase_keys
    preference = @user.user_ingredient_preferences.create!(
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Highland"
    )

    get api_user_ingredient_preference_url(preference),
        headers: auth_headers(@session.token),
        as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal preference.id, json["id"]
    assert_equal @user.id, json["userId"]
    assert_equal "canned", json["packagingForm"]
    assert_equal "diced", json["preparationStyle"]
    assert_equal "Highland", json["preferredBrand"]
    assert json.key?("usageCount"), "Should include usageCount"
    assert json.key?("lastUsedAt"), "Should include lastUsedAt"
    assert json.key?("displayContext"), "Should include displayContext"
  end

  def test_create_accepts_nested_params
    assert_difference("UserIngredientPreference.count") do
      post api_user_ingredient_preferences_url,
           params: {
             user_ingredient_preference: {
               ingredient_id: @ingredient.id,
               packaging_form: "frozen",
               preparation_style: "chopped",
               preferred_brand: "Highland"
             }
           },
           headers: auth_headers(@session.token),
           as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)

    assert_equal @ingredient.id, json["ingredient"]["id"]
    assert_equal "frozen", json["packagingForm"]
    assert_equal "chopped", json["preparationStyle"]
    assert_equal "Highland", json["preferredBrand"]
  end

  def test_update_accepts_nested_params
    preference = @user.user_ingredient_preferences.create!(
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Highland"
    )

    patch api_user_ingredient_preference_url(preference),
          params: {
            user_ingredient_preference: {
              packaging_form: "frozen",
              preparation_style: "chopped",
              preferred_brand: "Store Brand"
            }
          },
          headers: auth_headers(@session.token),
          as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal "frozen", json["packagingForm"]
    assert_equal "chopped", json["preparationStyle"]
    assert_equal "Store Brand", json["preferredBrand"]
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
