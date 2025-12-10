class Api::BaseController < ActionController::API
  include Api::TokenAuthentication
  
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  
  private
  
  def parameter_missing(exception)
    render json: { 
      status: 400, 
      message: "Missing parameter: #{exception.param}" 
    }, status: :bad_request
  end
  
  def not_found
    render json: { 
      status: 404, 
      message: "Record not found" 
    }, status: :not_found
  end
  
  def user_not_authorized
    render json: {
      status: 403,
      message: "You are not authorized to perform this action."
    }, status: :forbidden
  end
end
