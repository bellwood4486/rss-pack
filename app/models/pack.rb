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

require 'rss'

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
    merged_rss = RSS::Maker.make('2.0') do |maker|
      maker.channel.title = "#{user.email} - RssPack"
      # :TODO linkを見直す
      maker.channel.link = 'http://localhost:3000'
      maker.channel.description = "#{feeds.count}個のフィードを1つにまとめたRSSです。"

      maker.items.do_sort = true

      feeds.each do |feed|
        feed.refresh_rss!
        rss = RSS::Parser.parse(feed.content)
        rss.channel.items.each do |item|
          next if item.link.nil?
          maker.items.new_item do |new_item|
            new_item.title = item.title ||= 'No title'
            new_item.link = item.link
            new_item.date = item.date
          end
        end
      end
    end
    merged_rss.to_s
  end
end
