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


  def download_content
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
    req['If-Modified-Since'] = Time.zone.now.rfc2822
    req['Etag'] = ''
    res = Net::HTTP.start(uri.host, uri.port) { |http|
      http.request(req)
    }
    res.body.force_encoding('UTF-8')
  end

  private

  def parse_title(_content)
    "title of #{url}"
  end

  def clear_pack_rss
    pack.clear_rss
  end

  def rss_refresh_attributes
    { content: download_content, title: parse_title(content),
      rss_refreshed_at: Time.zone.now }
  end
end
