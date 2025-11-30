class ApplicationController < ActionController::Base
  include DestroyFlash
  include Pagy::Frontend
  before_action :set_user

  def set_user
    return unless cookies.signed[:session_token]
    resume_session
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by_token(cookies.signed[:session_token]) if cookies.signed[:session_token]
  end
end
