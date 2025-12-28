require "test_helper"

class Api::ShoppingListItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @session = sessions(:one)
    @shopping_list = shopping_lists(:one)
  end

  def test_index_returns_packaging_and_preparation
    get api_shopping_list_shopping_list_items_url(@shopping_list),
        headers: auth_headers(@session.token),
        as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert json.key?("shopping_list_items"), "Should have shopping_list_items key"
    assert json["shopping_list_items"].is_a?(Array), "Should be an array"

    if json["shopping_list_items"].any?
      item = json["shopping_list_items"].first
      assert item.key?("id"), "Should include id"
      assert item.key?("name"), "Should include name"
      assert item.key?("ingredient_id"), "Should include ingredient_id"
      assert item.key?("packaging_form"), "Should include packaging_form"
      assert item.key?("preparation_style"), "Should include preparation_style"
      assert item.key?("display_name"), "Should include display_name"
    end
  end

  def test_create_accepts_packaging_and_preparation
    assert_difference("ShoppingListItem.count") do
      post api_shopping_list_shopping_list_items_url(@shopping_list),
           params: {
             shopping_list_item: {
               name: "tomatoes",
               ingredient_id: ingredients(:canned_tomatoes).id,
               packaging_form: "canned",
               preparation_style: "diced"
             }
           },
           headers: auth_headers(@session.token),
           as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)

    assert_equal "tomatoes", json["name"]
    assert_equal ingredients(:canned_tomatoes).id, json["ingredient_id"]
    assert_equal "canned", json["packaging_form"]
    assert_equal "diced", json["preparation_style"]
    assert_equal "Canned Diced tomatoes", json["display_name"]
  end

  def test_create_allows_nil_packaging_and_preparation
    assert_difference("ShoppingListItem.count") do
      post api_shopping_list_shopping_list_items_url(@shopping_list),
           params: {
             shopping_list_item: {
               name: "Custom item",
               ingredient_id: nil,
               packaging_form: nil,
               preparation_style: nil
             }
           },
           headers: auth_headers(@session.token),
           as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)

    assert_equal "Custom item", json["name"]
    assert_nil json["ingredient_id"]
    assert_nil json["packaging_form"]
    assert_nil json["preparation_style"]
    assert_equal "Custom item", json["display_name"]
  end

  def test_update_accepts_packaging_and_preparation
    item = shopping_list_items(:one)

    patch api_shopping_list_item_url(item),
          params: {
            shopping_list_item: {
              packaging_form: "frozen",
              preparation_style: "chopped"
            }
          },
          headers: auth_headers(@session.token),
          as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal "frozen", json["packaging_form"]
    assert_equal "chopped", json["preparation_style"]

    item.reload
    assert_equal "frozen", item.packaging_form
    assert_equal "chopped", item.preparation_style
  end

  def test_index_includes_multiple_items
    # Create multiple items with ingredients
    item1 = @shopping_list.shopping_list_items.create!(
      name: "item_1",
      ingredient: ingredients(:one),
      packaging_form: "fresh",
      preparation_style: "diced"
    )

    item2 = @shopping_list.shopping_list_items.create!(
      name: "item_2",
      ingredient: ingredients(:two),
      packaging_form: "frozen",
      preparation_style: "chopped"
    )

    get api_shopping_list_shopping_list_items_url(@shopping_list),
        headers: auth_headers(@session.token),
        as: :json

    assert_response :success
    json = JSON.parse(response.body)

    # Should include both items
    assert json["shopping_list_items"].length >= 2, "Should have at least 2 items"
  end

  # Archive/Destroy tests
  def test_destroy_archives_item_via_api
    item = @shopping_list.shopping_list_items.create!(name: "Test item")

    assert_no_difference("ShoppingListItem.unscoped.count") do
      assert_difference("ShoppingListItem.count", -1) do
        delete api_shopping_list_item_url(item),
               headers: auth_headers(@session.token),
               as: :json
      end
    end

    assert_response :success

    # Verify item is archived
    archived_item = ShoppingListItem.unscoped.find(item.id)
    assert archived_item.archived?
  end

  def test_destroy_returns_archived_item_data
    item = @shopping_list.shopping_list_items.create!(
      name: "tomatoes",
      ingredient_id: ingredients(:one).id,
      packaging_form: "canned",
      preparation_style: "diced"
    )

    delete api_shopping_list_item_url(item),
           headers: auth_headers(@session.token),
           as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal true, json["archived"]
    assert_equal "tomatoes", json["name"]
    assert_equal ingredients(:one).id, json["ingredient_id"]
    assert_not_nil json["archived_at"]
  end

  def test_index_excludes_archived_items_by_default
    active_item = @shopping_list.shopping_list_items.create!(name: "Active")
    archived_item = @shopping_list.shopping_list_items.create!(name: "Archived")
    archived_item.archive!

    get api_shopping_list_shopping_list_items_url(@shopping_list),
        headers: auth_headers(@session.token),
        as: :json

    json = JSON.parse(response.body)
    names = json["shopping_list_items"].map { |item| item["name"] }

    assert_includes names, "Active"
    assert_not_includes names, "Archived"
  end

  def test_index_with_archived_param_includes_archived_items
    active_item = @shopping_list.shopping_list_items.create!(name: "Active")
    archived_item = @shopping_list.shopping_list_items.create!(name: "Archived")
    archived_item.archive!

    get api_shopping_list_shopping_list_items_url(@shopping_list),
        params: { include_archived: true },
        headers: auth_headers(@session.token),
        as: :json

    json = JSON.parse(response.body)
    names = json["shopping_list_items"].map { |item| item["name"] }

    assert_includes names, "Active"
    assert_includes names, "Archived"
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
