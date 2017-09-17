# frozen_string_literal: true

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

require 'open-uri'

class Blog < ApplicationRecord
  belongs_to :pack
  belongs_to :user
  has_one :rss_feed, dependent: :destroy
  attr_reader :feeds
  before_create :clear_pack_rss
  before_destroy :clear_pack_rss
  validates :url, presence: true
  validates :title, presence: true

  def parse
    html_doc = fetch(url)
    self.title = html_doc.title
    @feeds = parse_feeds(html_doc)
  end

  def parse_feeds(html_doc)
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

  private

  def fetch(url)
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    Nokogiri::HTML.parse(html, nil, charset)
  end

  def clear_pack_rss
    pack.clear_rss
  end
end
