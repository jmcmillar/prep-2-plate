require "test_helper"

class Admin::UserAnalyticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @admin.update!(admin: true)
    @target_user = users(:two)
    sign_in @admin
  end

  test "should get index as admin" do
    get admin_user_analytics_index_url(user_id: @target_user.id)
    assert_response :success
  end

  test "should assign facade for index" do
    get admin_user_analytics_index_url(user_id: @target_user.id)
    assert_not_nil assigns(:facade)
    assert_instance_of Admin::UserAnalytics::IndexFacade, assigns(:facade)
  end

  test "facade should load correct analytics user" do
    get admin_user_analytics_index_url(user_id: @target_user.id)
    facade = assigns(:facade)
    assert_equal @target_user, facade.analytics_user
  end

  test "non-admin should not access index" do
    sign_out @admin

    non_admin = users(:two)
    non_admin.update!(admin: false)
    sign_in non_admin

    assert_raises(Pundit::NotAuthorizedError) do
      get admin_user_analytics_index_url(user_id: @admin.id)
    end
  end

  test "unauthenticated user should be redirected from index" do
    sign_out @admin

    get admin_user_analytics_index_url(user_id: @target_user.id)
    assert_redirected_to new_user_session_url
  end
end
