class Pack < ApplicationRecord
  belongs_to :user
  has_many :feeds
  before_create :create_rss_token
  validates :rss_token, presence: true

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def refresh_rss
    return if rss_fresh?
    self.rss_content = pack_feed_contents
    self.rss_refreshed_at = Time.zone.now
    save
  end

  private

  def rss_fresh?
    rss_refreshed_at.present? &&
      (Time.zone.now - rss_refreshed_at) <= 1.hour
  end

  def create_rss_token
    self.rss_token = Pack.new_token
  end

  def pack_feed_contents
    feeds.first.content
    # res = Net::HTTP.get(
    #   URI.parse('https://bellwood4486.blogspot.com/feeds/posts/default?alt=rss'))
    # res.force_encoding('UTF-8')
  end
end
