require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  def test_has_many_user_ingredient_preferences
    assert_respond_to @user, :user_ingredient_preferences
  end

  def test_user_ingredient_preferences_association
    preference = UserIngredientPreference.create!(
      user: @user,
      ingredient: ingredients(:one),
      preferred_brand: "Test Brand",
      packaging_form: "frozen"
    )

    assert_includes @user.user_ingredient_preferences, preference
  end

  def test_destroys_user_ingredient_preferences_when_user_destroyed
    preference = UserIngredientPreference.create!(
      user: @user,
      ingredient: ingredients(:one),
      preferred_brand: "Test Brand",
      packaging_form: "frozen"
    )

    # Count how many preferences this user has (including fixtures)
    user_prefs_count = @user.user_ingredient_preferences.count

    assert_difference "UserIngredientPreference.count", -user_prefs_count do
      @user.destroy
    end
  end
end
