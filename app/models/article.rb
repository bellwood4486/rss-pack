class Article < ApplicationRecord
  belongs_to :feed

  scope :published_since, ->(datetime) { where("published_at > ?", datetime) }
end
