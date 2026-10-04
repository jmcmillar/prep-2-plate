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
      assert item.key?("ingredientId"), "Should include ingredientId (camelCase)"
      assert item.key?("packagingForm"), "Should include packagingForm (camelCase)"
      assert item.key?("preparationStyle"), "Should include preparationStyle (camelCase)"
      assert item.key?("brand"), "Should include brand"
      assert item.key?("displayName"), "Should include displayName (camelCase)"
      assert item.key?("displayNameWithBrand"), "Should include displayNameWithBrand"
      assert item.key?("archivedAt"), "Should include archivedAt (camelCase)"
      assert item.key?("archived"), "Should include archived"
      assert item.key?("createdAt"), "Should include createdAt (camelCase)"
      assert item.key?("updatedAt"), "Should include updatedAt (camelCase)"
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
    assert_equal ingredients(:canned_tomatoes).id, json["ingredientId"]
    assert_equal "canned", json["packagingForm"]
    assert_equal "diced", json["preparationStyle"]
    assert_equal "canned diced tomatoes", json["displayName"]
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
    assert_nil json["ingredientId"]
    assert_nil json["packagingForm"]
    assert_nil json["preparationStyle"]
    assert_equal "custom item", json["displayName"]
  end

  def test_update_accepts_packaging_and_preparation
    item = shopping_list_items(:canned_tomatoes)

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

    assert_equal "frozen", json["packagingForm"]
    assert_equal "chopped", json["preparationStyle"]

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
    assert_equal ingredients(:one).id, json["ingredientId"]
    assert_not_nil json["archivedAt"]
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


  def test_index_includes_aisle_and_whether_the_brand_is_remembered
    tomatoes = shopping_list_items(:canned_tomatoes)
    tomatoes.update!(brand: "Muir Glen")
    UserIngredientPreference.find_or_initialize_by(user: @user, ingredient: tomatoes.ingredient, packaging_form: "canned",
                                                   preparation_style: "diced").update!(preferred_brand: "Muir Glen")
    shopping_list_items(:custom_item).update!(brand: "Bounty")

    get api_shopping_list_shopping_list_items_url(@shopping_list), headers: auth_headers(@session.token), as: :json

    assert_response :success
    items = JSON.parse(response.body)["shopping_list_items"].index_by { |item| item["id"] }
    assert_equal "Canned & Jarred", items[tomatoes.id]["aisle"]
    assert items[tomatoes.id]["brandRemembered"]
    assert_nil items[shopping_list_items(:custom_item).id]["aisle"]
    assert_not items[shopping_list_items(:custom_item).id]["brandRemembered"]
  end

  def test_update_remembers_the_brand_by_default
    item = shopping_list_items(:custom_item)

    patch api_shopping_list_item_url(item), params: { shopping_list_item: { brand: "Bounty" } },
          headers: auth_headers(@session.token), as: :json

    assert_response :success
    assert JSON.parse(response.body)["brandRemembered"]
    assert_equal "Bounty", UserShoppingItemPreference.find_for_item(@user.id, item.name).preferred_brand
  end

  def test_update_without_remembering_keeps_the_brand_but_forgets_the_preference
    item = shopping_list_items(:custom_item)
    patch api_shopping_list_item_url(item), params: { shopping_list_item: { brand: "Bounty" } },
          headers: auth_headers(@session.token), as: :json

    patch api_shopping_list_item_url(item), params: { shopping_list_item: { brand: "Bounty" }, remember_brand: false },
          headers: auth_headers(@session.token), as: :json

    assert_response :success
    assert_not JSON.parse(response.body)["brandRemembered"]
    assert_equal "Bounty", item.reload.brand
    assert_nil UserShoppingItemPreference.find_for_item(@user.id, item.name)
  end

  def test_update_without_remembering_a_different_brand_keeps_the_saved_one
    item = shopping_list_items(:custom_item)
    patch api_shopping_list_item_url(item), params: { shopping_list_item: { brand: "Bounty" } },
          headers: auth_headers(@session.token), as: :json

    patch api_shopping_list_item_url(item), params: { shopping_list_item: { brand: "Viva" }, remember_brand: false },
          headers: auth_headers(@session.token), as: :json

    assert_equal "Bounty", UserShoppingItemPreference.find_for_item(@user.id, item.name).preferred_brand
  end

  def test_restore_brings_back_a_checked_off_item
    item = shopping_list_items(:canned_tomatoes)
    delete api_shopping_list_item_url(item), headers: auth_headers(@session.token), as: :json
    assert_not ShoppingListItem.exists?(item.id)

    assert_difference -> { @shopping_list.reload.shopping_list_items_count }, 1 do
      post restore_api_shopping_list_item_url(item), headers: auth_headers(@session.token), as: :json
    end

    assert_response :success
    assert_equal item.id, JSON.parse(response.body)["id"]
    assert ShoppingListItem.exists?(item.id)
  end

  def test_restore_only_reaches_the_users_own_items
    other = shopping_list_items(:two) # on user two's list
    other.archive!

    post restore_api_shopping_list_item_url(other), headers: auth_headers(@session.token), as: :json

    assert_response :not_found
    assert other.reload.archived?
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
