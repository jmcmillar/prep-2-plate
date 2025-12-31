require "test_helper"

class VendorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vendor = vendors(:healthy_meal_co)
    @inactive_vendor = vendors(:inactive_vendor)
  end

  def test_index
    get vendors_url
    assert_response :success
  end

  def test_index_shows_active_vendors
    get vendors_url
    assert_select "h3", text: @vendor.business_name
  end

  def test_show_active_vendor
    get vendor_url(@vendor)
    assert_response :success
  end

  def test_show_displays_vendor_information
    get vendor_url(@vendor)
    assert_select "h1", text: @vendor.business_name
  end

  def test_show_displays_vendor_offerings
    get vendor_url(@vendor)
    @vendor.offerings.each do |offering|
      assert_select "h3", text: offering.name
    end
  end
end
