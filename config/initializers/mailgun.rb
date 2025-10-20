Mailgun.configure do |config|
  if Rails.env.production?
    config.api_key = ENV.fetch("MAILGUN_API_KEY", nil) 
  end
end
