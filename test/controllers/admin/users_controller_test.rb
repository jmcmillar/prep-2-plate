require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @admin.update!(admin: true)
    post session_url, params: { email_address: @admin.email_address, password: "password" }
    @user = User.create!(email_address: "test@example.com", password: "password", first_name: "John", last_name: "Doe")
  end

  test "should get index" do
    get admin_users_url
    assert_response :success
  end

  test "should get show" do
    get admin_user_url(@user)
    assert_response :success
  end

  test "should get new" do
    get new_admin_user_url
    assert_response :success
  end

  test "should create user with first and last name" do
    assert_difference('User.count', 1) do
      post admin_users_url, params: {
        user: {
          email_address: "newuser@example.com",
          first_name: "Jane",
          last_name: "Smith",
          admin: false
        }
      }
    end

    assert_redirected_to admin_users_url
    user = User.find_by(email_address: "newuser@example.com")
    assert_equal "Jane", user.first_name
    assert_equal "Smith", user.last_name
  end

  test "should get edit" do
    get edit_admin_user_url(@user)
    assert_response :success
  end

  test "should update user with first and last name" do
    patch admin_user_url(@user), params: {
      user: {
        first_name: "Updated",
        last_name: "Name"
      }
    }

    assert_redirected_to admin_users_url
    @user.reload
    assert_equal "Updated", @user.first_name
    assert_equal "Name", @user.last_name
  end

  test "should update user admin status" do
    patch admin_user_url(@user), params: {
      user: {
        admin: true
      }
    }

    assert_redirected_to admin_users_url
    @user.reload
    assert_equal true, @user.admin
  end
end
