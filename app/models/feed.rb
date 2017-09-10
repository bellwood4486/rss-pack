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
  before_destroy :clear_pack_rss
  validates :url, presence: true
  validates :title, presence: true
  validates :content, presence: true

  def refresh
    # :TODO ETag/modified_dateを使ったチェックを入れる
    update! content: download_content, title: parse_title(content),
            rss_refreshed_at: Time.zone.now
    # self.content = download_content
    # self.title = parse_title content
  end

  private

  def download_content
    res = Net::HTTP.get(URI.parse(url))
    res.force_encoding('UTF-8')
  end

  def parse_title(_content)
    "title of #{url}"
  end

  def clear_pack_rss
    pack.clear_rss
  end
end