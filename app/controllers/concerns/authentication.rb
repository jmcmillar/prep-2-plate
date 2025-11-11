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
    if request.headers['Authorization'].present? && request.headers['Authorization'].start_with?('Bearer ')
      token = request.headers['Authorization'].split(' ').last
      Current.session = Session.find_by(id: token)
    elsif !is_api_controller? && cookies.signed[:session_id].present?
      Current.session = Session.find_by(id: cookies.signed[:session_id])
    else
      Current.session = nil
    end
    
    Current.session
  end

  def find_session_by_cookie
    return nil if is_api_controller?
    Session.find_by(id: cookies.signed[:session_id])
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
      unless is_api_controller?
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
    cookies.delete(:session_id) unless is_api_controller?
    Current.session = nil
  end

  def is_api_controller?
    self.class.ancestors.include?(ActionController::API) || request.path.start_with?('/api')
  end
end
