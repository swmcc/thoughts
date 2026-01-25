class Thought < ApplicationRecord
  MAX_CONTENT_LENGTH = 140

  SOURCES = %w[web cli iphone].freeze

  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }
  validates :source, inclusion: { in: SOURCES }
  validates :view_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :public_id, presence: true, uniqueness: true

  before_validation :generate_public_id, on: :create
  before_save :normalize_tags
  before_save :fetch_link_preview, if: -> { content_changed? && respond_to?(:link_url=) }

  # Use public_id in URLs instead of id
  def to_param
    public_id
  end

  scope :recent, -> { order(created_at: :desc) }
  scope :with_tag, ->(tag) { where("? = ANY(tags)", tag) }
  scope :search, ->(query) { where("content ILIKE ?", "%#{query}%") }

  def increment_view_count!
    increment!(:view_count)
  end

  def source_label
    case source
    when "web" then "Written from web"
    when "cli" then "Written from CLI"
    when "iphone" then "Written from iPhone"
    else "Written from #{source}"
    end
  end

  private

  def generate_public_id
    self.public_id ||= SecureRandom.alphanumeric(12)
  end

  def normalize_tags
    self.tags = tags.map(&:downcase).map(&:strip).uniq.reject(&:blank?) if tags.present?
  end

  def fetch_link_preview
    # Extract first URL from content
    url = content&.match(%r{https?://[^\s]+})&.to_s
    return clear_link_preview if url.blank?

    begin
      # Follow redirects to get final URL
      final_url = follow_redirects(url)

      # Check if it's a direct image link
      if image_url?(final_url)
        self.link_url = url
        self.link_title = nil
        self.link_description = nil
        # Store the original URL, not the presigned S3 URL (which expires)
        self.link_image = url
      else
        # Try to fetch OG data
        og = OpenGraphReader.fetch(url)
        if og&.og&.title.present? || og&.og&.image&.url.present?
          self.link_url = url
          self.link_title = og.og.title&.truncate(100)
          self.link_description = og.og.description&.truncate(200)
          self.link_image = og.og.image&.url
        else
          clear_link_preview
        end
      end
    rescue StandardError
      clear_link_preview
    end
  end

  def follow_redirects(url, limit = 5)
    return url if limit <= 0

    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
      http.head(uri.request_uri)
    end

    if response.is_a?(Net::HTTPRedirection) && response["location"]
      follow_redirects(response["location"], limit - 1)
    else
      url
    end
  rescue StandardError
    url
  end

  def image_url?(url)
    return false if url.blank?
    uri = URI.parse(url)
    path = uri.path.to_s.downcase
    query = uri.query.to_s.downcase

    # Check path extension
    return true if path.match?(/\.(jpg|jpeg|png|gif|webp|svg)$/)

    # Check Active Storage URLs
    return true if url.include?("active_storage") && url.include?("blob")

    # Check S3 URLs with content-type in query params (e.g., response-content-type=image%2Fpng)
    return true if query.include?("response-content-type=image")

    # Check for filename with image extension in query params
    return true if query.match?(/filename[^&]*\.(jpg|jpeg|png|gif|webp|svg)/)

    false
  rescue StandardError
    false
  end

  def clear_link_preview
    self.link_url = nil
    self.link_title = nil
    self.link_description = nil
    self.link_image = nil
  end
end
