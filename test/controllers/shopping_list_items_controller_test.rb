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
end
