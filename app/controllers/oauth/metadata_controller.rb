module Oauth
  class MetadataController < ActionController::API
    include OauthUrls

    # GET /.well-known/oauth-protected-resource (RFC 9728)
    def protected_resource
      render json: {
        resource: mcp_resource_url,
        authorization_servers: [ public_base_url ],
        bearer_methods_supported: [ "header" ]
      }
    end

    # GET /.well-known/oauth-authorization-server (RFC 8414)
    def authorization_server
      render json: {
        issuer: public_base_url,
        authorization_endpoint: "#{public_base_url}/oauth/authorize",
        token_endpoint: "#{public_base_url}/oauth/token",
        registration_endpoint: "#{public_base_url}/oauth/register",
        response_types_supported: [ "code" ],
        grant_types_supported: [ "authorization_code", "refresh_token" ],
        code_challenge_methods_supported: [ "S256" ],
        token_endpoint_auth_methods_supported: [ "none", "client_secret_post", "client_secret_basic" ],
        client_id_metadata_document_supported: false
      }
    end
  end
end
