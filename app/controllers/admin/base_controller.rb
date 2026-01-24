module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin

    private

    def require_admin
      unless current_admin
        redirect_to new_admin_session_path, alert: "Please log in to access the admin area."
      end
    end

    def current_admin
      @current_admin ||= AdminUser.find_by(id: session[:admin_user_id]) if session[:admin_user_id]
    end
    helper_method :current_admin
  end
end
