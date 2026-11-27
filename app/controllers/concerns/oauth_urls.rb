# Public URLs for OAuth discovery. Set APP_URL (e.g. https://thoughts.example.com)
# if the app sits behind a proxy that doesn't forward the original scheme/host.
module OauthUrls
  extend ActiveSupport::Concern

  private

  def public_base_url
    ENV.fetch("APP_URL", request.base_url).chomp("/")
  end

  def mcp_resource_url
    "#{public_base_url}/mcp"
  end

  def protected_resource_metadata_url
    "#{public_base_url}/.well-known/oauth-protected-resource"
  end
end
