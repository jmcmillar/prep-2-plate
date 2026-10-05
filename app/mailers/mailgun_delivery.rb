require 'mailgun-ruby'

class MailgunDelivery
  def initialize(values)
    @values = values
    @mg_client = Mailgun::Client.new(ENV.fetch("MAILGUN_API_KEY"))
    @domain = "prep2plate.com"
  end

  def deliver!(mail)
    message_params = {
      from:    mail[:from].to_s,
      to:      mail[:to].to_s,
      subject: mail.subject,
      text:    body_of(mail, "text/plain"),
      html:    body_of(mail, "text/html")
    }.compact
    @mg_client.send_message(@domain, message_params)
  end

  private

  # A message with only one format (Devise's HTML-only emails) has no parts,
  # so its body is that format; sending it as text shows raw HTML
  def body_of(mail, mime_type)
    if mail.multipart?
      mail.all_parts.find { |part| part.mime_type == mime_type && !part.attachment? }&.body&.decoded
    elsif (mail.mime_type || "text/plain") == mime_type
      mail.body.decoded
    end
  end
end
