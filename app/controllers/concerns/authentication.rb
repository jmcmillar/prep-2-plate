module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  private

  def authenticated?
    resume_session.present?
  end

  def require_authentication
    resume_session
    request_authentication unless Current.session
  end

  def resume_session
    session = nil

    if request.headers['Authorization'].present? && request.headers['Authorization'].start_with?('Bearer ')
      token = request.headers['Authorization'].split(' ').last
      session = Session.find_by_token(token)

      # Log suspicious activity
      if session && session.suspicious_activity?(current_ip: request.remote_ip, current_user_agent: request.user_agent)
        Rails.logger.warn("Suspicious session activity detected - Session ID: #{session.id}, IP: #{request.remote_ip}")
      end
    elsif !is_api_controller? && cookies.signed[:session_token].present?
      token = cookies.signed[:session_token]
      session = Session.find_by_token(token)

      # Log suspicious activity
      if session && session.suspicious_activity?(current_ip: request.remote_ip, current_user_agent: request.user_agent)
        Rails.logger.warn("Suspicious session activity detected - Session ID: #{session.id}, IP: #{request.remote_ip}")
      end
    end

    Current.session = session
    log_authentication_attempt(session.present?)

    Current.session
  end

  def find_session_by_cookie
    return nil if is_api_controller?
    return nil unless cookies.signed[:session_token].present?

    Session.find_by_token(cookies.signed[:session_token])
  end

  def request_authentication
    if request.format.json? || request.path.start_with?('/api')
      render json: { 
        status: 401, 
        message: 'Authentication required.' 
      }, status: :unauthorized
    else
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      log_authentication_event('session_created', user_id: user.id, session_id: session.id)

      unless is_api_controller?
        cookies.signed.permanent[:session_token] = {
          value: session.token,
          httponly: true,
          same_site: :lax,
          secure: Rails.env.production?
        }
      end
    end
  end

  def terminate_session
    if Current.session
      log_authentication_event('session_terminated', session_id: Current.session.id)
      Current.session.destroy
    end
    cookies.delete(:session_token) unless is_api_controller?
    Current.session = nil
  end

  def is_api_controller?
    self.class.ancestors.include?(ActionController::API) || request.path.start_with?('/api')
  end

  def log_authentication_attempt(success)
    return unless Rails.env.production? || Rails.env.development?

    event_type = success ? 'authentication_success' : 'authentication_failure'
    log_authentication_event(event_type)
  end

  def log_authentication_event(event_type, additional_data = {})
    return unless Rails.env.production? || Rails.env.development?

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
