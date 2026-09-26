require "test_helper"

class OfferingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @offering = offerings(:grilled_chicken_veggies)
    @vendor = vendors(:healthy_meal_co)
    sign_in users(:two)
  end

  def test_index_filters_by_search_term
    get offerings_url, params: { q: { name_cont: @offering.name } }

    assert_response :success
    assert_select "h3", text: /#{Regexp.escape(@offering.name)}/
    other = Offering.active_vendor.where.not(name: @offering.name).first
    assert_select "h3", text: /#{Regexp.escape(other.name)}/, count: 0 if other
  end

  def test_requires_sign_in
    sign_out :user
    get offerings_url
    assert_redirected_to new_user_session_url
  end

  def test_index
    get offerings_url
    assert_response :success
  end

  def test_index_shows_featured_offerings
    get offerings_url
    featured_offerings = Offering.featured
    featured_offerings.each do |offering|
      assert_select "h3", text: offering.name
    end
  end

  def test_index_shows_all_offerings
    get offerings_url
    assert_select "h3", text: @offering.name
  end

  def test_show
    get offering_url(@offering)
    assert_response :success
  end

  def test_show_displays_offering_name
    get offering_url(@offering)
    assert_select "h1", text: @offering.name
  end

  def test_show_displays_vendor_information
    get offering_url(@offering)
    assert_select "h3", text: @offering.vendor.business_name
  end

  def test_show_displays_ingredients
    get offering_url(@offering)
    @offering.offering_ingredients.each do |ingredient|
      assert_select "li", text: /#{ingredient.ingredient.name}/i
    end
  end

  def test_show_displays_price_points
    get offering_url(@offering)
    @offering.offering_price_points.each do |price_point|
      assert_select "div", text: /#{price_point.serving_size}/
    end
  end
end
