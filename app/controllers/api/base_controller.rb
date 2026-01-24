module Api
  class BaseController < ActionController::API
    before_action :authenticate_for_write, only: [ :create, :update, :destroy ]

    private

    def authenticate_for_write
      unless current_admin
        render json: { error: "Invalid or missing API token" }, status: :unauthorized
      end
    end

    def current_admin
      return @current_admin if defined?(@current_admin)

      token = request.headers["Authorization"]&.gsub(/^Bearer /, "")
      @current_admin = AdminUser.find_by(api_token: token) if token.present?
    end

    def authenticated?
      current_admin.present?
    end
  end
end
