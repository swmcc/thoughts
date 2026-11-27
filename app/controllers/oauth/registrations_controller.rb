module Oauth
  # POST /oauth/register — RFC 7591 dynamic client registration. Registering
  # grants nothing by itself: every authorization still needs the admin to
  # sign in and approve.
  class RegistrationsController < ActionController::API
    def create
      confidential = params[:token_endpoint_auth_method].present? &&
                     params[:token_endpoint_auth_method] != "none"
      client, secret = Client.register(client_name: params[:client_name],
                                       redirect_uris: params[:redirect_uris],
                                       confidential: confidential)

      if client.persisted?
        render json: registration_json(client, secret), status: :created
      else
        render json: { error: "invalid_redirect_uri", error_description: client.errors.full_messages.to_sentence },
               status: :bad_request
      end
    end

    private

    def registration_json(client, secret)
      json = {
        client_id: client.client_id,
        client_id_issued_at: client.created_at.to_i,
        client_name: client.client_name,
        redirect_uris: client.redirect_uris,
        grant_types: [ "authorization_code", "refresh_token" ],
        response_types: [ "code" ],
        token_endpoint_auth_method: secret ? "client_secret_post" : "none"
      }
      json.merge!(client_secret: secret, client_secret_expires_at: 0) if secret
      json
    end
  end
end
