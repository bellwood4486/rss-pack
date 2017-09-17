# frozen_string_literal: true

# == Schema Information
#
# Table name: rss_feeds
#
#  id           :integer          not null, primary key
#  url          :string
#  content      :text
#  refreshed_at :datetime
#  etag         :string
#  blog_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_type :string
#  title        :string
#

require 'net/http'

class RssFeed < ApplicationRecord
  DEFAULT_TITLE = 'NO_NAME'
  belongs_to :blog
  after_initialize :refresh, if: -> { content.nil? }
  before_save :update_refreshed_time, if: -> { content_changed? }
  validates :content_type, presence: true
  validates :url, presence: true
  validates :title, presence: true

  def refresh
    assign_attributes(content: fetch_content)
  end

  def refresh!
    update_attibutes!(content: fetch_content)
  end

  def rss20
    parse_as_rss20(content)
  end

  private

  def fetch_content
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
    req['If-None-Match'] = etag
    res = Net::HTTP.start(
      uri.host, uri.port,
      use_ssl: uri.scheme == 'https'
    ) do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.request(req)
    end

    case res
    when Net::HTTPNotModified
      content # 前回保存しておいたものを返して無駄な通信を避ける
    when Net::HTTPSuccess
      self.etag = res['Etag']
      self.content = res.body.force_encoding('UTF-8')
      content
    end
  end

  def parse_as_rss20(rss_source)
    rss = nil
    begin
      rss = RSS::Parser.parse(rss_source)
    rescue RSS::InvalidRSSError
      rss = RSS::Parser.parse(rss_source, false)
    end
    rss.to_rss('2.0')
  end

  def update_refreshed_time
    self.refreshed_at = Time.zone.now
  end
end
