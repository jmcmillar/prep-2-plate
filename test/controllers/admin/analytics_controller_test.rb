require "test_helper"

class Admin::AnalyticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @admin.update!(admin: true)
    sign_in @admin
  end

  test "should get shopping_lists as admin" do
    get admin_analytics_shopping_lists_url
    assert_response :success
  end

  test "should assign facade for shopping_lists" do
    get admin_analytics_shopping_lists_url
    assert_not_nil assigns(:facade)
    assert_instance_of Admin::Analytics::ShoppingListsFacade, assigns(:facade)
  end

  test "should get user_preferences as admin" do
    get admin_analytics_user_preferences_url
    assert_response :success
  end

  test "should assign facade for user_preferences" do
    get admin_analytics_user_preferences_url
    assert_not_nil assigns(:facade)
    assert_instance_of Admin::Analytics::UserPreferencesFacade, assigns(:facade)
  end

  test "non-admin should not access shopping_lists" do
    sign_out @admin

    non_admin = users(:two)
    non_admin.update!(admin: false)
    sign_in non_admin

    assert_raises(Pundit::NotAuthorizedError) do
      get admin_analytics_shopping_lists_url
    end
  end

  test "non-admin should not access user_preferences" do
    sign_out @admin

    non_admin = users(:two)
    non_admin.update!(admin: false)
    sign_in non_admin

    assert_raises(Pundit::NotAuthorizedError) do
      get admin_analytics_user_preferences_url
    end
  end

  test "unauthenticated user should be redirected from shopping_lists" do
    sign_out @admin

    get admin_analytics_shopping_lists_url
    assert_redirected_to new_user_session_url
  end

  test "unauthenticated user should be redirected from user_preferences" do
    sign_out @admin

    get admin_analytics_user_preferences_url
    assert_redirected_to new_user_session_url
  end
end
