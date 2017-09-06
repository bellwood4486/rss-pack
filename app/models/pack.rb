class Pack < ApplicationRecord
  belongs_to :user
  has_many :feeds
  before_create :create_rss_token

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def refresh_rss_content
    self.rss_content = create_rss_content
  end

  private

  def create_rss_token
    self.rss_token = Pack.new_token
  end

  def create_rss_content
    res = Net::HTTP.get(
      URI.parse('https://bellwood4486.blogspot.com/feeds/posts/default?alt=rss'))
    res.force_encoding("UTF-8")
  end
end
