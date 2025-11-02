# app/controllers/concerns/authentication.rb
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
    # API/Mobile: Check for bearer token (but only if it looks like a real bearer token)
    if request.headers['Authorization'].present? && request.headers['Authorization'].start_with?('Bearer ')
      token = request.headers['Authorization'].split(' ').last
      Current.session = Session.find_by(id: token)
    # Web: Check for cookie
    elsif cookies.signed[:session_id].present?
      Current.session = find_session_by_cookie
    else
      Current.session = nil
    end
    
    Current.session
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id])
  end

  def request_authentication
    # API requests → JSON error
    if request.format.json? || request.path.start_with?('/api')
      render json: { 
        status: 401, 
        message: 'Authentication required.' 
      }, status: :unauthorized
    # Web requests → redirect to login page
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
      # Only set cookie for web requests (not API)
      unless request.path.start_with?('/api')
        cookies.signed.permanent[:session_id] = {
          value: session.id,
          httponly: true,
          same_site: :lax
        }
      end
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
    Current.session = nil
  end
end
