require "test_helper"

class ShoppingListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email: @user.email, password: "password" }
  end

  test "should get index" do
    get shopping_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_shopping_list_url
    assert_response :success
  end

  test "should create shopping_list" do
    assert_difference 'ShoppingList.count', 1 do
      post shopping_lists_url, params: { shopping_list: { name: "Groceries" } }
    end

    assert_redirected_to shopping_lists_path
  end

  test "should show shopping_list" do
    list = ShoppingList.create!(name: "My List", user: @user)
    get shopping_list_url(list)
    assert_response :success
  end

  test "should update shopping_list" do
    list = ShoppingList.create!(name: "Old Name", user: @user)

    patch shopping_list_url(list), params: { shopping_list: { current: true } }

    assert_redirected_to shopping_lists_path
    list.reload
    assert_equal "Old Name", list.name
    assert_equal true, list.current
  end

  test "should destroy shopping_list" do
    list = ShoppingList.create!(name: "To Delete", user: @user)

    assert_difference('ShoppingList.count', -1) do
      delete shopping_list_url(list)
    end

    assert_redirected_to shopping_lists_path
  end
end
