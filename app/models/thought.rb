class Thought < ApplicationRecord
  MAX_CONTENT_LENGTH = 140

  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }
  validates :view_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :public_id, presence: true, uniqueness: true

  before_validation :generate_public_id, on: :create
  before_save :normalize_tags
  before_save :fetch_link_preview, if: :content_changed?

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
      og = OpenGraphReader.fetch(url)
      if og
        self.link_url = url
        self.link_title = og.og.title&.truncate(100)
        self.link_description = og.og.description&.truncate(200)
        self.link_image = og.og.image&.url
      else
        clear_link_preview
      end
    rescue StandardError
      clear_link_preview
    end
  end

  def clear_link_preview
    self.link_url = nil
    self.link_title = nil
    self.link_description = nil
    self.link_image = nil
  end
end
