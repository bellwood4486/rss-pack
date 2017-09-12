# frozen_string_literal: true

# == Schema Information
#
# Table name: feeds
#
#  id               :integer          not null, primary key
#  url              :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pack_id          :integer
#  content          :text
#  user_id          :integer
#  rss_refreshed_at :datetime
#  etag             :string
#  last_modified    :string
#

require 'net/http'

class Feed < ApplicationRecord
  belongs_to :pack
  belongs_to :user
  before_create :clear_pack_rss
  before_destroy :clear_pack_rss
  validates :url, presence: true
  validates :title, presence: true
  validates :content, presence: true

  def refresh_rss
    # :TODO ETag/modified_dateを使ったチェックを入れる
    assign_attributes(rss_refresh_attributes)
  end

  def refresh_rss!
    # :TODO ETag/modified_dateを使ったチェックを入れる
    update_attibutes!(rss_refresh_attributes)
  end

  private

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
      content # 前回保存しておいたものを返す
    when Net::HTTPSuccess
      update_attributes!(last_modified: res['Last-Modified'],
                         etag: res['Etag'],
                         content: res.body.force_encoding('UTF-8'))
      content
    end
  rescue
    nil
  end

  def parse_title(_content)
    "title of #{url}"
  end

  def clear_pack_rss
    pack.clear_rss
  end

  def rss_refresh_attributes
    { content: fetch_content, title: parse_title(content),
      rss_refreshed_at: Time.zone.now }
  end
end
