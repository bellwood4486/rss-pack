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

  def refresh_rss_if_outdated
    return if rss_fresh?
    update! rss_content: pack_feeds, rss_refreshed_at: Time.zone.now
  end

  def clear_rss
    update! rss_content: nil, rss_refreshed_at: nil
  end

  private

  def rss_fresh?
    rss_refreshed_at.present? &&
      (Time.zone.now - rss_refreshed_at) <= 1.hour
  end

  def create_rss_token
    self.rss_token = Pack.new_token
  end

  def pack_feeds
    # TODO あとで実装
    feeds.first.content
  end
end
