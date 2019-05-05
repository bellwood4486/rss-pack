class Article < ApplicationRecord
  SUMMARY_MAX_LENGTH = 1000

  belongs_to :feed

  validates! :title, presence: true
  validates! :link, presence: true

  scope :published_since, ->(datetime) { where("published_at > ?", datetime) }

  before_validation :truncate_summary

  private

    def truncate_summary
      self.summary = summary&.truncate(SUMMARY_MAX_LENGTH)
    end
end
