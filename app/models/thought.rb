class Thought < ApplicationRecord
  MAX_CONTENT_LENGTH = 140

  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }
  validates :view_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_save :normalize_tags

  scope :recent, -> { order(created_at: :desc) }
  scope :with_tag, ->(tag) { where("? = ANY(tags)", tag) }

  def increment_view_count!
    increment!(:view_count)
  end

  private

  def normalize_tags
    self.tags = tags.map(&:downcase).map(&:strip).uniq.reject(&:blank?) if tags.present?
  end
end
