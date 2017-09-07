class Feed < ApplicationRecord
  belongs_to :user
  belongs_to :pack
  validates :url, presence: true
  validates :title, presence: true
  validates :content, presence: true

  def refresh
    self.content = download_content
    self.title = parse_title content
  end

  private

  def download_content
    res = Net::HTTP.get(URI.parse(url))
    res.force_encoding('UTF-8')
  end

  def parse_title(content)
    "title of #{url}"
  end
end
