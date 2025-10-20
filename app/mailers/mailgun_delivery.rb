require 'mailgun-ruby'

class MailgunDelivery
  def initialize(values)
    @values = values
    @mg_client = Mailgun::Client.new(ENV.fetch("MAILGUN_API_KEY"))
    @domain = "prep2plate.com"
  end

  def deliver!(mail)
    message_params =  {
      from:    mail[:from].to_s,
      to:      mail[:to].to_s,
      subject: mail.subject,
      text:    mail.body.decoded,
      html:    mail.html_part&.body&.decoded
    }
    @mg_client.send_message(@domain, message_params)
  end
end
