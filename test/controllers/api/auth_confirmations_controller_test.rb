require "test_helper"

class Api::AuthConfirmationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  def resend(email)
    post api_auth_confirmation_url(format: :json), params: { user: { email: email } }
  end

  test "resends the link to an unconfirmed user" do
    users(:two).update_columns(confirmed_at: nil)

    assert_emails 1 do
      resend " Two@Example.com "
    end
    assert_response :success
  end

  test "answers the same for confirmed and unknown emails without sending anything" do
    assert_no_emails do
      resend users(:one).email
      assert_response :success
      confirmed_body = response.body

      resend "nobody@example.com"
      assert_response :success
      assert_equal confirmed_body, response.body
    end
  end
end
