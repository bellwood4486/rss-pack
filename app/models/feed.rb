require "rss"

class Feed < ApplicationRecord
  RELOAD_INTERVAL = ENV["RSSPACK_FEED_RELOAD_INTERVAL"].to_i || 3600

  has_many :articles, dependent: :destroy
  has_many :subscriptions, dependent: :nullify

  before_save :update_reloaded_at

  def self.discover!(url)
    discover(url).select(&:save)
  end

  def self.discover(url)
    Feeds::Fetcher.discover(url).map do |discovered|
      feed = Feed.find_or_initialize_by(url: discovered[:url],
                                        content_type: discovered[:content_type])
      # タイトルは常に最新のものを使う
      feed.title = discovered[:title] || "NO_NAME"
      feed
    end
  end

  def reload_articles
    return unless reload_interval_spent?

    fetched = Feeds::Fetcher.fetch(url, etag: etag)
    return unless fetched[:modified?]

    unless update({
      etag: fetched[:etag],
      rss_content: fetched[:body],
      articles: build_articles(fetched[:body]),
    })
      # TODO: ログに残す
    end
  end

  private

    def update_reloaded_at
      if etag_changed? || rss_content_changed?
        self.reloaded_at = Time.zone.now
      end
    end

    def reload_interval_spent?
      return true if reloaded_at.blank?

      (Time.zone.now - reloaded_at) > RELOAD_INTERVAL.seconds
    end

    def build_articles(rss_content)
      rss20 = parse_to_rss20(rss_content)
      rss20.channel.items.map do |item|
        Article.new do |a|
          a.title = item.title ||= "No title"
          a.link = item.link
          a.published_at = item.date
        end
      end
    end

    def parse_to_rss20(rss_content)
      begin
        rss = RSS::Parser.parse(rss_content)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(rss_content, false)
      end

      rss20 = rss.to_rss("2.0")
      if rss.feed_type == "atom"
        fix_rss20_link!(rss, rss20)
      end
      rss20
    end

    # atom -> rss20 変換時に、atom側のlink要素が複数あると期待したリンクが
    # rss20に割当たらない問題を修復するためのコード
    def fix_rss20_link!(atom, rss20)
      atom.items.each_with_index do |atom_item, idx|
        atom_link = atom_item.links.find {|l| l.rel == "alternate" }
        if atom_link.present?
          rss20.channel.items[idx].link = atom_link.href
        end
      end
    end
end
