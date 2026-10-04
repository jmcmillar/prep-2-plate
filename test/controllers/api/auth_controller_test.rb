require "test_helper"

class Api::AuthControllerTest < ActionDispatch::IntegrationTest
  def sign_in(email, password = "password")
    post api_auth_sign_in_url(format: :json), params: { user: { email: email, password: password } }
  end

  test "a confirmed user gets a session token" do
    assert_difference "Session.count", 1 do
      sign_in users(:one).email
    end

    assert_response :success
    assert_equal "Bearer #{Session.last.token}", response.headers["Authorization"]
  end

  test "an unconfirmed user is refused until they confirm" do
    users(:two).update_columns(confirmed_at: nil)

    assert_no_difference "Session.count" do
      sign_in users(:two).email
    end

    assert_response :forbidden
    body = JSON.parse(response.body)
    assert_equal "unconfirmed", body["reason"]
    assert_equal I18n.t("devise.failure.unconfirmed"), body["message"]
  end

  test "a locked user is refused" do
    users(:two).update_columns(locked_at: Time.current)

    sign_in users(:two).email

    assert_response :forbidden
    assert_equal "locked", JSON.parse(response.body)["reason"]
  end

  test "a wrong password is refused without revealing account state" do
    users(:two).update_columns(confirmed_at: nil)

    sign_in users(:two).email, "wrong"

    assert_response :unauthorized
    assert_nil JSON.parse(response.body)["reason"]
  end
end
