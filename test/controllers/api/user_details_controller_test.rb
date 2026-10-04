require "test_helper"

class Api::UserDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @headers = { "Authorization" => "Bearer #{@user.sessions.create!.token}" }
  end

  test "show includes the household size" do
    @user.update!(household_size: 4)

    get api_user_details_url(format: :json), headers: @headers

    assert_response :success
    assert_equal 4, JSON.parse(response.body)["householdSize"]
  end

  test "update sets and clears the household size" do
    patch api_user_details_url(format: :json), params: { user: { household_size: "3" } }, headers: @headers
    assert_response :success
    assert_equal 3, @user.reload.household_size

    patch api_user_details_url(format: :json), params: { user: { household_size: "" } }, headers: @headers
    assert_response :success
    assert_nil @user.reload.household_size
  end

  test "update rejects a household size out of range" do
    patch api_user_details_url(format: :json), params: { user: { household_size: "0" } }, headers: @headers

    assert_response :unprocessable_entity
    assert_nil @user.reload.household_size
  end

  test "update ignores email changes" do
    patch api_user_details_url(format: :json), params: { user: { email: "new@example.com", first_name: "Renamed" } }, headers: @headers

    assert_response :success
    @user.reload
    assert_equal "two@example.com", @user.email
    assert_nil @user.unconfirmed_email
    assert_equal "Renamed", @user.first_name
  end
end
