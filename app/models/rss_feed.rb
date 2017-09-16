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

class RssFeed < ApplicationRecord
  DEFAULT_TITLE = 'NO_NAME'
  belongs_to :blog
  after_initialize :refresh, if: -> { content.nil? }
  before_save :update_refreshed_time, if: -> { content_changed? }
  validates :url, presence: true
  validates :content_type, presence: true

  def refresh
    assign_attributes(refresh_attributes)
  end

  def refresh!
    update_attibutes!(refresh_attributes)
  end

  private

  def refresh_attributes
    { content: fetch_content, title: title_of(content) }
  end

  def fetch_content
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
    req['If-None-Match'] = etag
    res = Net::HTTP.start(uri.host, uri.port,
                          use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.request(req)
    end

    case res
    when Net::HTTPNotModified
      content # 前回保存しておいたものを返して無駄な通信を避ける
    when Net::HTTPSuccess
      update_attributes!(last_modified: res['Last-Modified'],
                         etag: res['Etag'],
                         content: res.body.force_encoding('UTF-8'))
      content
    end
  rescue
    nil
  end

  def title_of(content)
    # :TODO nokogiriでパースする
    'dummy title'
  rescue
    return DEFAULT_TITLE
  end

  def update_refreshed_time
    self.refreshed_at = Time.zone.now
  end
end
