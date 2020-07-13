class Api::V1::ApiController < ApplicationController
  skip_before_action :check_terms_accepted_and_logged_in
  
  resource_description do
    api_version 'v1'
  end

  skip_before_action :verify_authenticity_token
  before_action :authenticate_user
  rescue_from ActionController::ParameterMissing, with: :param_missing_handler
  rescue_from Apipie::ParamMissing, with: :param_missing_handler
  rescue_from Apipie::ParamInvalid, with: :invalid_param_handler
  rescue_from CanCan::AccessDenied, with: :unauthorized_handler
  rescue_from ActiveRecord::RecordInvalid, with: :could_not_save
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_handler
  helper_method :current_user_session, :current_user

  private
  def param_missing_handler e
    render json: {error: 'PARAMS_MISSING', message: e}, status: 422
  end

  def could_not_save e
      render json: {error: 'COULD_NOT_SAVE', message: e}, status: 422
  end

  def invalid_param_handler e
    render json: {error: 'INVALID_PARAM', message: e}, status: 422
  end

  def unauthorized_handler e
    render json: {error: 'UNAUTHORIZED', message: e}, status: 403
  end

  def record_not_found_handler e
    render json: {error: 'NOT_FOUND', message: e}, status: 404
  end

  def authenticate_user
    if current_user.nil?
      render json: {error: 'NOT_AUTHENTICATED'}, status: 401
    end
  end
end

