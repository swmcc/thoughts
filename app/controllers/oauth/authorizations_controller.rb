module Oauth
  # The browser step: sign in as the admin, then approve or deny the client.
  class AuthorizationsController < ApplicationController
    layout "admin"

    before_action :load_client_and_redirect_uri
    before_action :validate_request_params
    before_action :require_admin

    # GET /oauth/authorize
    def new
    end

    # POST /oauth/authorize
    def create
      if params[:decision] == "approve"
        code = AuthorizationCode.issue(client: @client, admin_user: current_admin,
                                       redirect_uri: @redirect_uri, code_challenge: params[:code_challenge])
        redirect_to_client(code: code, state: params[:state])
      else
        redirect_to_client(error: "access_denied", state: params[:state])
      end
    end

    private

    # An unknown client or unregistered redirect URI must not redirect anywhere.
    def load_client_and_redirect_uri
      @client = Client.find_by(client_id: params[:client_id])
      @redirect_uri = params[:redirect_uri].to_s
      return if @client&.redirect_uri_allowed?(@redirect_uri)

      render plain: "Unknown client or redirect URI.", status: :bad_request
    end

    def validate_request_params
      if params[:response_type] != "code"
        redirect_to_client(error: "unsupported_response_type", state: params[:state])
      elsif params[:code_challenge].blank? || params[:code_challenge_method] != "S256"
        redirect_to_client(error: "invalid_request", error_description: "PKCE with S256 is required",
                           state: params[:state])
      end
    end

    def require_admin
      return if current_admin

      session[:return_to_after_login] = request.fullpath
      redirect_to new_admin_session_path, alert: "Sign in to connect #{@client.client_name}."
    end

    def current_admin
      @current_admin ||= AdminUser.find_by(id: session[:admin_user_id]) if session[:admin_user_id]
    end
    helper_method :current_admin

    def redirect_to_client(**query)
      uri = URI.parse(@redirect_uri)
      query_params = URI.decode_www_form(uri.query.to_s) + query.compact.map { |k, v| [ k.to_s, v ] }
      uri.query = URI.encode_www_form(query_params)
      redirect_to uri.to_s, allow_other_host: true
    end
  end
end
