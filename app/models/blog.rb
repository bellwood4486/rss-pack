# == Schema Information
#
# Table name: blogs
#
#  id         :integer          not null, primary key
#  url        :string
#  title      :string
#  pack_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Blog < ApplicationRecord
  belongs_to :pack
  belongs_to :user
  has_one :rss_feed, dependent: :destroy

  before_create :clear_pack_rss
  before_destroy :clear_pack_rss
  validates :url, presence: true
  validates :title, presence: true

  def fetch_feeds
    feed1 = Feed.new(url: 'hoge', content_type: 'fuga')
    feed2 = Feed.new(url: 'foo', content_type: 'bar')
    [feed1, feed2]
  end

  private


  def parse_title(_content)
    "title of #{url}"
  end

  def clear_pack_rss
    pack.clear_rss
  end

end
