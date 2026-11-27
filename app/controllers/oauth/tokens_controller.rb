module Oauth
  # POST /oauth/token
  class TokensController < ActionController::API
    before_action :authenticate_client

    def create
      tokens =
        case params[:grant_type]
        when "authorization_code" then exchange_code
        when "refresh_token" then AccessToken.refresh(params[:refresh_token], client: @client)
        else return oauth_error("unsupported_grant_type")
        end

      if tokens
        response.headers["Cache-Control"] = "no-store"
        render json: tokens
      else
        oauth_error("invalid_grant")
      end
    end

    private

    def exchange_code
      code = AuthorizationCode.redeem(params[:code], client: @client,
                                      redirect_uri: params[:redirect_uri],
                                      code_verifier: params[:code_verifier])
      code && AccessToken.issue(client: @client, admin_user: code.admin_user)
    end

    def authenticate_client
      client_id, secret = basic_credentials || [ params[:client_id], params[:client_secret] ]
      @client = Client.find_by(client_id: client_id)
      oauth_error("invalid_client", status: :unauthorized) unless @client&.valid_secret?(secret)
    end

    def basic_credentials
      encoded = request.authorization.to_s[/\ABasic (.+)\z/, 1]
      return nil if encoded.blank?

      Base64.decode64(encoded).split(":", 2).map { |part| CGI.unescape(part) }
    end

    def oauth_error(code, status: :bad_request)
      render json: { error: code }, status: status
    end
  end
end
