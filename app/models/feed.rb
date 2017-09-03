class Feed < ApplicationRecord
  belongs_to :user
  validates :url, presence: true
  validates :title, presence: true

  def fetch
    self.title = 'title of ' + url
  end
end
