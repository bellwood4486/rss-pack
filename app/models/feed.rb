# frozen_string_literal: true

# == Schema Information
#
# Table name: feeds
#
#  id           :integer          not null, primary key
#  url          :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  pack_id      :integer
#  content      :text
#  refreshed_at :datetime
#  etag         :string
#  content_type :string
#

require 'net/http'
require 'open-uri'

class Feed < ApplicationRecord
  DEFAULT_TITLE = 'NO_NAME'
  belongs_to :pack
  after_initialize :refresh, if: -> { content.nil? }
  before_save :update_refreshed_time, if: -> { content_changed? }
  before_create :clear_pack_rss
  before_destroy :clear_pack_rss
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

  def self.discover(url)
    html_doc = fetch(url)
    parse_feeds(html_doc)
  end

  private

  def self.fetch(url)
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    Nokogiri::HTML.parse(html, nil, charset)
  end

  def self.parse_feeds(html_doc)
    feeds = []
    html_doc.xpath("//link[@rel='alternate']").each do |link|
      attrs = link.attributes
      feeds << Feed.new(
        content_type: attrs['type']&.value,
        title: attrs['title']&.value,
        url: attrs['href']&.value
      )
    end
    feeds
  end

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

  def clear_pack_rss
    pack.clear_rss
  end
end
