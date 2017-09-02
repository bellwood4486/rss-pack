class Feed < ApplicationRecord
  validates :url, presence: true
  validates :title, presence: true
end
