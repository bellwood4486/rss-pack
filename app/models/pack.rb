# frozen_string_literal: true

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
  has_and_belongs_to_many :feeds
  after_initialize :create_rss_token, if: -> { rss_token.blank? }
  validates :rss_token, presence: true

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def fresh?
    rss_refreshed_at.present? &&
        (Time.zone.now - rss_refreshed_at) <= EasySettings.rss_fresh_duration
  end

  def refresh!(rss_url)
    return if fresh?
    update! rss_content: pack_feeds(rss_url), rss_refreshed_at: Time.zone.now
  end

  def clear_rss
    update! rss_content: nil, rss_refreshed_at: nil
  end

  private

  def create_rss_token
    self.rss_token = Pack.new_token
  end

  def pack_feeds(rss_url)
    merged_rss = RSS::Maker.make('2.0') do |maker|
      make_pack_header maker, rss_url
      make_pack_items maker
    end
    merged_rss.to_s
  end

  def make_pack_header(maker, rss_url)
    maker.channel.title = 'RssPack'
    maker.channel.link = rss_url
    maker.channel.description = "#{rss_refreshed_at}以降の更新フィード"
  end

  def make_pack_items(maker)
    maker.items.do_sort = true
    feeds.each do |feed|
      feed.refresh!
      feed.rss20.channel.items.select { |i| should_pack?(i) }.map do |item|
        maker.items.new_item do |new_item|
          new_item.title = item.title ||= 'No title'
          new_item.link = item.link
          new_item.date = item.date
        end
      end
    end
  end

  def should_pack?(rss20_item)
    rss20_item.link.present? &&
        (rss_refreshed_at.blank? || rss20_item.date > rss_refreshed_at)
  end
end
