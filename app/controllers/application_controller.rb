class ApplicationController < ActionController::API
  include JsonWebToken
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split.last if header

    begin
      @decoded = jwt_decode(header)
      @current_user = User.find(@decoded[:user_id])

      if @current_user.status == 'Disabled'
        render json: { error: 'Your account is currently disabled' },
               status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def check_admin
    return if @current_user.admin?

    render json: { error: "You don't have enough permission to complete this request" },
           status: :unauthorized
  end
end
