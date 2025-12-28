require "test_helper"

class ShoppingListItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:one)
    @shopping_list = shopping_lists(:one)
    sign_in @user
  end

  def test_create_with_packaging_and_preparation
    assert_difference("ShoppingListItem.count") do
      post shopping_list_items_path(@shopping_list), params: {
        shopping_list_item: {
          name: "tomatoes",
          ingredient_id: ingredients(:canned_tomatoes).id,
          packaging_form: "canned",
          preparation_style: "diced"
        }
      }
    end

    assert_redirected_to shopping_list_items_path(@shopping_list)

    item = ShoppingListItem.last
    assert_equal "tomatoes", item.name
    assert_equal ingredients(:canned_tomatoes).id, item.ingredient_id
    assert_equal "canned", item.packaging_form
    assert_equal "diced", item.preparation_style
  end

  def test_create_via_json_includes_display_name
    post shopping_list_items_path(@shopping_list),
         params: {
           shopping_list_item: {
             name: "carrots",
             ingredient_id: ingredients(:one).id,
             packaging_form: "fresh",
             preparation_style: "diced"
           }
         },
         as: :json

    assert_response :created
    json = JSON.parse(response.body)

    assert_equal "carrots", json["name"]
    assert json.key?("display_name"), "Should include display_name in JSON response"
    assert_equal "Fresh Diced carrots", json["display_name"]
  end

  def test_update_with_packaging_and_preparation
    item = shopping_list_items(:one)

    patch item_path(item), params: {
      shopping_list_item: {
        packaging_form: "frozen",
        preparation_style: "chopped"
      }
    }

    assert_redirected_to shopping_list_items_path(@shopping_list)

    item.reload
    assert_equal "frozen", item.packaging_form
    assert_equal "chopped", item.preparation_style
  end

  def test_create_allows_nil_packaging_and_preparation
    assert_difference("ShoppingListItem.count") do
      post shopping_list_items_path(@shopping_list), params: {
        shopping_list_item: {
          name: "Custom item",
          ingredient_id: nil,
          packaging_form: nil,
          preparation_style: nil
        }
      }
    end

    item = ShoppingListItem.last
    assert_equal "Custom item", item.name
    assert_nil item.ingredient_id
    assert_nil item.packaging_form
    assert_nil item.preparation_style
  end

  # Archive/Destroy tests
  def test_destroy_archives_item_instead_of_deleting
    item = shopping_list_items(:one)

    assert_no_difference("ShoppingListItem.unscoped.count") do
      assert_difference("ShoppingListItem.count", -1) do
        delete item_path(item)
      end
    end

    assert_redirected_to shopping_list_items_path(item.shopping_list)

    # Item should be archived, not deleted
    archived_item = ShoppingListItem.unscoped.find(item.id)
    assert archived_item.archived?
  end

  def test_destroy_decrements_counter_cache
    shopping_list = shopping_lists(:one)
    item = shopping_list.shopping_list_items.create!(name: "Test")
    initial_count = shopping_list.reload.shopping_list_items_count

    delete item_path(item)

    assert_equal initial_count - 1, shopping_list.reload.shopping_list_items_count
  end

  def test_destroy_shows_success_message
    item = shopping_list_items(:one)

    delete item_path(item)

    assert_equal "Item was successfully completed.", flash[:notice]
  end

  def test_destroy_json_returns_success
    item = shopping_list_items(:one)

    delete item_path(item), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json["archived"]
  end
end
