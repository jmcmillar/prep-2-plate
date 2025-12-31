require "test_helper"

class Admin::OfferingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:one)
    @offering = offerings(:grilled_chicken_veggies)
    @vendor = vendors(:healthy_meal_co)
    sign_in @admin_user
  end

  def test_index
    get admin_vendor_offerings_url(@vendor)
    assert_response :success
  end

  def test_show
    get admin_offering_url(@offering)
    assert_response :success
  end

  def test_new
    get new_admin_vendor_offering_url(@vendor)
    assert_response :success
  end

  def test_create_with_valid_attributes
    assert_difference "Offering.count", 1 do
      post admin_vendor_offerings_url(@vendor), params: {
        offering: {
          vendor_id: @vendor.id,
          name: "New Offering",
          base_serving_size: 2,
          featured: false
        }
      }
    end
    assert_redirected_to admin_offering_url(Offering.last)
  end

  def test_create_with_nested_ingredients
    assert_difference ["Offering.count", "OfferingIngredient.count"], 1 do
      post admin_vendor_offerings_url(@vendor), params: {
        offering: {
          vendor_id: @vendor.id,
          name: "New Offering with Ingredients",
          base_serving_size: 2,
          offering_ingredients_attributes: {
            "0" => {
              ingredient_id: ingredients(:chicken_breast).id,
              measurement_unit_id: measurement_units(:pound).id,
              quantity: "1",
              notes: "boneless"
            }
          }
        }
      }
    end
  end

  def test_create_with_nested_price_points
    assert_difference ["Offering.count", "OfferingPricePoint.count"], 1 do
      post admin_vendor_offerings_url(@vendor), params: {
        offering: {
          vendor_id: @vendor.id,
          name: "New Offering with Pricing",
          base_serving_size: 2,
          offering_price_points_attributes: {
            "0" => {
              serving_size: 2,
              price: 24.99
            }
          }
        }
      }
    end
  end

  def test_create_with_invalid_attributes
    assert_no_difference "Offering.count" do
      post admin_vendor_offerings_url(@vendor), params: {
        offering: {
          vendor_id: nil,
          name: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  def test_edit
    get edit_admin_offering_url(@offering)
    assert_response :success
  end

  def test_update_with_valid_attributes
    patch admin_offering_url(@offering), params: {
      offering: {
        name: "Updated Offering Name"
      }
    }
    assert_redirected_to admin_offering_url(@offering)
    @offering.reload
    assert_equal "Updated Offering Name", @offering.name
  end

  def test_update_with_invalid_attributes
    original_name = @offering.name
    patch admin_offering_url(@offering), params: {
      offering: {
        name: "",
        vendor_id: nil
      }
    }
    assert_response :unprocessable_entity
    @offering.reload
    assert_equal original_name, @offering.name
  end

  def test_destroy
    assert_difference "Offering.count", -1 do
      delete admin_offering_url(@offering)
    end
    assert_redirected_to admin_vendor_offerings_url(@vendor)
  end
end
