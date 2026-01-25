module SourceDetectable
  extend ActiveSupport::Concern

  SOURCES = {
    web: "web",
    cli: "cli",
    iphone: "iphone"
  }.freeze

  private

  def detect_source
    user_agent = request.user_agent.to_s

    if mobile_safari?(user_agent)
      SOURCES[:iphone]
    elsif cli_client?(user_agent)
      SOURCES[:cli]
    else
      SOURCES[:web]
    end
  end

  def mobile_safari?(user_agent)
    user_agent.match?(/iPhone|iPad/i) && user_agent.match?(/AppleWebKit/i)
  end

  def cli_client?(user_agent)
    user_agent.blank? ||
      user_agent.match?(/\b(curl|httpie|wget|python-requests|ruby|insomnia|postman)\b/i)
  end
end
