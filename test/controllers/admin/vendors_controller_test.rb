require "test_helper"

class Admin::VendorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:one)
    @vendor = vendors(:healthy_meal_co)
    sign_in @admin_user
  end

  def test_index
    get admin_vendors_url
    assert_response :success
  end

  def test_show
    get admin_vendor_url(@vendor)
    assert_response :success
  end

  def test_new
    get new_admin_vendor_url
    assert_response :success
  end

  def test_create_with_valid_attributes
    assert_difference "Vendor.count", 1 do
      post admin_vendors_url, params: {
        vendor: {
          business_name: "New Vendor",
          contact_name: "John Doe",
          contact_email: "john@newvendor.com",
          status: "active"
        }
      }
    end
    assert_redirected_to admin_vendor_url(Vendor.last)
  end

  def test_create_with_invalid_attributes
    assert_no_difference "Vendor.count" do
      post admin_vendors_url, params: {
        vendor: {
          business_name: "",
          contact_name: "",
          contact_email: "invalid"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  def test_edit
    get edit_admin_vendor_url(@vendor)
    assert_response :success
  end

  def test_update_with_valid_attributes
    patch admin_vendor_url(@vendor), params: {
      vendor: {
        business_name: "Updated Name"
      }
    }
    assert_redirected_to admin_vendor_url(@vendor)
    @vendor.reload
    assert_equal "Updated Name", @vendor.business_name
  end

  def test_update_with_invalid_attributes
    original_name = @vendor.business_name
    patch admin_vendor_url(@vendor), params: {
      vendor: {
        business_name: "",
        contact_email: "invalid"
      }
    }
    assert_response :unprocessable_entity
    @vendor.reload
    assert_equal original_name, @vendor.business_name
  end

  def test_destroy
    assert_difference "Vendor.count", -1 do
      delete admin_vendor_url(@vendor)
    end
    assert_redirected_to admin_vendors_url
  end
end
