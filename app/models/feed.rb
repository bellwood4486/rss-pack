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
#  content      :text
#  refreshed_at :datetime
#  etag         :string
#  content_type :string
#  user_id      :integer
#

class Feed < ApplicationRecord
  DEFAULT_TITLE = 'NO_NAME'
  has_and_belongs_to_many :packs
  before_save :update_refreshed_time, if: -> { content_changed? }
  before_create :refresh, if: -> { content.nil? }
  before_create :clear_pack_rss
  before_destroy :clear_pack_rss
  validates :content_type, presence: true
  validates :url, presence: true
  validates :title, presence: true

  def refresh
    assign_attributes(fetch_content)
  end

  def refresh!
    update_attributes!(fetch_content)
  end

  def rss20
    parse_as_rss20(content)
  end

  def self.discover(url)
    Feeds::Fetcher.discover(url).map do |discovered|
      Feed.new do |feed|
        feed.title = discovered[:title]
        feed.url = discovered[:url]
        feed.content_type = discovered[:content_type]
      end
    end
  end

  private

  def fetch_content
    f = Feeds::Fetcher.fetch url, etag: etag,
                             response_body_if_not_modified: content
    { etag: f[:etag], content: f[:body] }
  end

  def parse_as_rss20(rss_source)
    rss = nil
    begin
      rss = RSS::Parser.parse(rss_source)
    rescue RSS::InvalidRSSError
      rss = RSS::Parser.parse(rss_source, false)
    end
    rss20 = rss.to_rss('2.0')
    rss.feed_type == 'atom' ? fix_rss20_link(rss, rss20) : rss20
  end

  def update_refreshed_time
    self.refreshed_at = Time.zone.now
  end

  def clear_pack_rss
    packs.map(&:clear_rss)
  end

  # atom -> rss20 変換時に、atom側のlink要素が複数あると期待したリンクが
  # rss20に割当たらない問題を修復するためのコード
  def fix_rss20_link(atom, rss20)
    atom.items.each_with_index do |atom_item, idx|
      atom_link = atom_item.links.find { |l| l.rel == 'alternate' }
      next if atom_link.blank?
      rss20.channel.items[idx].link = atom_link.href
    end
    rss20
  end
end
