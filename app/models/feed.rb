class Feed < ApplicationRecord
  validates :url, presence: true
  validates :title, presence: true

  def fetch
    self.title = 'title of ' + url
  end
end
