class Feed < ApplicationRecord
  belongs_to :user
  belongs_to :pack
  validates :url, presence: true
  validates :title, presence: true

  def fetch
    self.title = 'title of ' + url
  end
end
