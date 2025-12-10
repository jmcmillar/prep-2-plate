module Api::TokenAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  private

  def authenticated?
    Current.session.present?
  end

  def require_authentication
    authenticate_with_bearer_token
    request_authentication unless Current.session
  end

  def authenticate_with_bearer_token
    return unless authorization_header_present?

    token = extract_bearer_token
    session = Session.find_by_token(token)

    if session&.suspicious_activity?(current_ip: request.remote_ip, current_user_agent: request.user_agent)
      Rails.logger.warn("AUTH_EVENT: Suspicious API session activity - Session ID: #{session.id}, IP: #{request.remote_ip}")
    end

    Current.session = session
    Current.user = session&.user
    log_authentication_attempt(session.present?)
    Current.session
  end

  def authorization_header_present?
    request.headers['Authorization'].present? &&
      request.headers['Authorization'].start_with?('Bearer ')
  end

  def extract_bearer_token
    request.headers['Authorization'].split(' ').last
  end

  def request_authentication
    render json: {
      status: 401,
      message: 'Authentication required. Please provide a valid bearer token.'
    }, status: :unauthorized
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      log_authentication_event('api_session_created', user_id: user.id, session_id: session.id)
    end
  end

  def terminate_session
    if Current.session
      log_authentication_event('api_session_terminated', session_id: Current.session.id)
      Current.session.destroy
      Current.session = nil
    end
  end

  def log_authentication_attempt(success)
    event_type = success ? 'api_authentication_success' : 'api_authentication_failure'
    log_authentication_event(event_type)
  end

  def log_authentication_event(event_type, additional_data = {})
    log_data = {
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      path: request.path,
      timestamp: Time.current
    }.merge(additional_data)

    Rails.logger.info("AUTH_EVENT: #{log_data.to_json}")
  end
end
