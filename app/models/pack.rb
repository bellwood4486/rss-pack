# == Schema Information
#
# Table name: packs
#
#  id               :integer          not null, primary key
#  rss_token        :string
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  rss_content      :text
#  rss_refreshed_at :datetime
#  name             :string
#

class Pack < ApplicationRecord
  belongs_to :user
  has_many :feeds
  after_initialize :create_rss_token, if: -> { rss_token.nil? }
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
