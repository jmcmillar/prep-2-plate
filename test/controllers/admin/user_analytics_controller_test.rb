require "test_helper"

class Admin::UserAnalyticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:one)
    @admin.update!(admin: true)
    @target_user = users(:two)
    sign_in @admin
  end

  test "should get index as admin" do
    get admin_user_user_analytics_url(@target_user.id)
    assert_response :success
  end

  test "should assign facade for index" do
    get admin_user_user_analytics_url(@target_user.id)
    assert_not_nil controller.instance_variable_get(:@facade)
    assert_instance_of Admin::UserAnalytics::IndexFacade, controller.instance_variable_get(:@facade)
  end

  test "facade should load correct analytics user" do
    get admin_user_user_analytics_url(@target_user.id)
    facade = controller.instance_variable_get(:@facade)
    assert_equal @target_user, facade.analytics_user
  end

  test "non-admin should not access index" do
    sign_out @admin

    non_admin = users(:two)
    non_admin.update!(admin: false)
    sign_in non_admin

    get admin_user_user_analytics_url(@admin.id)
    assert_redirected_to root_path
  end

  test "unauthenticated user should be redirected from index" do
    sign_out @admin

    get admin_user_user_analytics_url(@target_user.id)
    assert_redirected_to new_user_session_url
  end
end
