class ApplicationController < ActionController::Base
  include DestroyFlash
  before_action :set_user

  def set_user
    return unless cookies.signed[:session_id]
    resume_session
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end
end
