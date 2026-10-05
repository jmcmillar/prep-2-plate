require "test_helper"
require "minitest/mock"

class MailgunDeliveryTest < ActiveSupport::TestCase
  # Captures what would be sent to Mailgun
  class FakeClient
    attr_reader :params

    def send_message(_domain, params)
      @params = params
    end
  end

  def deliver(mail)
    client = FakeClient.new
    ENV.stub(:fetch, "test-key") do
      Mailgun::Client.stub(:new, client) do
        MailgunDelivery.new({}).deliver!(mail)
      end
    end
    client.params
  end

  test "sends an HTML-only email as HTML, not as text" do
    mail = Mail.new(to: "a@example.com", from: "b@example.com", subject: "Hi") do
      content_type "text/html; charset=UTF-8"
      body "<p>Hello</p>"
    end

    params = deliver(mail)

    assert_equal "<p>Hello</p>", params[:html]
    assert_not params.key?(:text)
  end

  test "sends both parts of a multipart email" do
    mail = Mail.new(to: "a@example.com", from: "b@example.com", subject: "Hi") do
      text_part { body "Hello" }
      html_part do
        content_type "text/html; charset=UTF-8"
        body "<p>Hello</p>"
      end
    end

    params = deliver(mail)

    assert_equal "Hello", params[:text]
    assert_equal "<p>Hello</p>", params[:html]
  end

  test "sends a text-only email as text" do
    mail = Mail.new(to: "a@example.com", from: "b@example.com", subject: "Hi", body: "Hello")

    params = deliver(mail)

    assert_equal "Hello", params[:text]
    assert_not params.key?(:html)
  end
end
