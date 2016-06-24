class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_filter :verity_authenticity_token

  rescue_from ActiveRecord::NestedAttributes::TooManyRecords do |exception|
    render json: { errors: exception.message }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { errors: exception.message }, status: 422
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: exception.message }, status: 422
  end
end
