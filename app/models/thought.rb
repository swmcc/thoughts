class Thought < ApplicationRecord
  MAX_CONTENT_LENGTH = 140

  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }
  validates :view_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :public_id, presence: true, uniqueness: true

  before_validation :generate_public_id, on: :create
  before_save :normalize_tags

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
end
