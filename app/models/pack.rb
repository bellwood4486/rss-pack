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
  after_initialize :create_rss_token, if: -> { rss_token.nil? }
  validates :rss_token, presence: true

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def refresh!(rss_url)
    return if rss_fresh?
    update! rss_content: pack_feeds(rss_url), rss_refreshed_at: Time.zone.now
  end

  def clear_rss
    update! rss_content: nil, rss_refreshed_at: nil
  end

  private

  def rss_fresh?
    # :TODO あとで戻す
    return false
    # rss_refreshed_at.present? &&
    #   (Time.zone.now - rss_refreshed_at) <= 1.hour
  end

  def create_rss_token
    self.rss_token = Pack.new_token
  end

  def pack_feeds(rss_url)
    merged_rss = RSS::Maker.make('2.0') do |maker|
      maker.channel.title = 'RssPack'
      maker.channel.link = rss_url
      maker.channel.description = "#{feeds.count}個のフィードを1つにまとめたRSSです。"

      maker.items.do_sort = true

      feeds.each do |feed|
        feed.refresh!
        feed.rss20.channel.items.select { |i| i.link.present? }.map do |item|
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
