# Streamable HTTP MCP endpoint (stateless, JSON responses), protected by
# OAuth access tokens issued by Oauth::TokensController.
class McpController < ActionController::API
  include OauthUrls

  before_action :authenticate_access_token

  # POST /mcp
  def create
    server = ThoughtsMcp::Server.build(access_token: @access_token)
    response_json = server.handle_json(request.raw_post)

    if response_json
      render json: response_json
    else
      head :accepted
    end
  end

  # GET/DELETE /mcp — no server-initiated streams or sessions in stateless mode
  def unsupported
    response.headers["Allow"] = "POST"
    head :method_not_allowed
  end

  private

  def authenticate_access_token
    raw = request.authorization.to_s[/\ABearer (.+)\z/, 1]
    @access_token = Oauth::AccessToken.authenticate(raw)
    return if @access_token

    response.headers["WWW-Authenticate"] =
      %(Bearer resource_metadata="#{protected_resource_metadata_url}")
    render json: { error: "invalid_token" }, status: :unauthorized
  end
end
