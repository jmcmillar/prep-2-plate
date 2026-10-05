require "test_helper"

class DeviseMailerTest < ActionMailer::TestCase
  test "confirmation email is styled HTML from the mailer layout" do
    mail = Devise::Mailer.confirmation_instructions(users(:one), "token123")

    assert_equal "text/html", mail.mime_type
    assert_includes mail.body.to_s, "<html"
    assert_includes mail.body.to_s, ".button {"
    assert_includes mail.body.to_s, "confirmation_token=token123"
  end
end
