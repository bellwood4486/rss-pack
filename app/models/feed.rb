require "rss"

class Feed < ApplicationRecord
  FETCH_INTERVAL = ENV["RSSPACK_FEED_FETCH_INTERVAL"]&.to_i || 3600

  has_many :articles, dependent: :destroy
  has_many :subscriptions, dependent: :nullify

  class FeedError < StandardError; end

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

  def reload_articles!
    unless fetch_interval_spent?
      logger.debug "skip to fetch feed(#{url}). the interval time does not spent."
      return
    end

    fetched = fetch_feed!
    if fetched[:modified?]
      logger.info "fetched a feed(#{url})."
    else
      logger.info "try to fetch feed(#{url}). but it is not modified."
      return
    end

    update_feed!(fetched)
  end

  private

    def fetch_interval_spent?
      return true if fetched_at.blank?

      (Time.zone.now - fetched_at) > FETCH_INTERVAL.seconds
    end

    def build_articles!(rss_content)
      begin
        rss_feed = RSS::Parser.parse(rss_content)
      rescue RSS::InvalidRSSError
        rss_feed = RSS::Parser.parse(rss_content, false)
      end

      case rss_feed.feed_type
      when "rss"
        build_articles_for_rss(rss_feed)
      when "atom"
        build_articles_for_atom(rss_feed)
      else
        raise FeedError, "unsupport feed type. feed: #{rss_feed}"
      end
    end

    def build_articles_for_atom(atom_feed)
      atom_feed.entries.map do |entry|
        Article.new do |a|
          a.title = entry.title.content ||= "No title"
          a.link = entry.link.href
          a.published_at = entry.published.content
        end
      end
    end

    def build_articles_for_rss(rss_feed)
      rss20 = rss_feed.to_rss("2.0")
      rss20.channel.items.map do |item|
        Article.new do |a|
          a.title = item.title ||= "No title"
          a.link = item.link
          a.published_at = item.date
        end
      end
    end

    def fetch_feed!
      begin
        feed = Feeds::Fetcher.fetch!(url, etag: etag)
      rescue SocketError, URI::Error => e
        raise FeedError, "failed to fetch feed(#{url}). #{e}"
      else
        update!(fetched_at: Time.zone.now)
      end
      feed
    end

    def update_feed!(fetched)
      update!({
        etag: fetched[:etag],
        rss_content: fetched[:body],
        articles: build_articles!(fetched[:body]),
      })
    rescue ActiveRecord::ActiveRecordError => e
      raise FeedError, "failed to update the article record. #{e}"
    end
end
