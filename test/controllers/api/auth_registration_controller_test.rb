require "test_helper"

class Api::AuthRegistrationControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "sign up creates an unconfirmed user and a current list, emails a confirmation link, and returns no token" do
    assert_difference "User.count", 1 do
      assert_emails 1 do
        post api_auth_sign_up_url(format: :json), params: {
          user: { first_name: "Ada", last_name: "Lovelace", email: "ada@example.com", password: "secret1", password_confirmation: "secret1" }
        }
      end
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_nil body.dig("data", "token")
    assert body.dig("data", "confirmationRequired")

    user = User.find_by!(email: "ada@example.com")
    assert_not user.confirmed?
    assert_empty user.sessions
    assert_equal [ [ "My List", true ] ], user.shopping_lists.pluck(:name, :current)
  end

  test "sign up reports why it failed and creates nothing" do
    assert_no_difference [ "User.count", "ShoppingList.count" ] do
      post api_auth_sign_up_url(format: :json), params: {
        user: { first_name: "Ada", last_name: "", email: "ada@example.com", password: "secret1", password_confirmation: "secret1" }
      }
    end

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body).dig("status", "message"), "Last name can't be blank"
  end
end
