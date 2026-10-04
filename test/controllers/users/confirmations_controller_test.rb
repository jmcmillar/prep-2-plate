require "test_helper"

class Users::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @user.update_columns(confirmed_at: nil)
    @user.send(:generate_confirmation_token!)
    @token = @user.confirmation_token
  end

  test "confirming shows a link that opens the app's log in with the email filled in" do
    get user_confirmation_url(confirmation_token: @token)

    assert_response :success
    assert @user.reload.confirmed?
    assert_select "a[href=?]", "prep2plate://sign-in?confirmed=1&email=two%40example.com", text: "Open Prep2Plate"
  end

  test "opening the link again still shows the hand-off" do
    get user_confirmation_url(confirmation_token: @token)
    get user_confirmation_url(confirmation_token: @token)

    assert_response :success
    assert_select "a", text: "Open Prep2Plate"
  end

  test "an invalid token shows the resend form" do
    get user_confirmation_url(confirmation_token: "nope")

    assert_response :unprocessable_entity
    assert_not @user.reload.confirmed?
  end
end
