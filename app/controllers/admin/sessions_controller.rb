module Admin
  class SessionsController < ApplicationController
    layout "admin"

    def new
      redirect_to admin_root_path if current_admin
    end

    def create
      admin = AdminUser.find_by(email: params[:email])
      if admin&.authenticate(params[:password])
        return_to = session.delete(:return_to_after_login)
        reset_session
        session[:admin_user_id] = admin.id
        redirect_to safe_return_path(return_to) || admin_root_path, notice: "Welcome back!"
      else
        flash.now[:alert] = "Invalid email or password"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:admin_user_id)
      redirect_to new_admin_session_path, notice: "You have been logged out."
    end

    def regenerate_token
      current_admin.regenerate_api_token!
      redirect_to admin_root_path, notice: "API token regenerated successfully."
    end

    private

    # Only same-site paths (set by Oauth::AuthorizationsController), never "//host".
    def safe_return_path(path)
      path if path.is_a?(String) && path.start_with?("/") && !path.start_with?("//")
    end

    def current_admin
      @current_admin ||= AdminUser.find_by(id: session[:admin_user_id]) if session[:admin_user_id]
    end
    helper_method :current_admin
  end
end
