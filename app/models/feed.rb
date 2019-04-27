require "rss"

class Feed < ApplicationRecord
  FETCH_INTERVAL = ENV["RSSPACK_FEED_FETCH_INTERVAL"]&.to_i || 3600

  has_many :articles, dependent: :destroy
  has_many :subscriptions, dependent: :nullify

  class FeedError < StandardError; end

  def fetch_and_save!
    fetch
    save!
  rescue ActiveRecord::ActiveRecordError => e
    raise FeedError, "failed to save feed(#{url}). #{e}"
  end

  def fetch
    unless fetch_interval_spent?
      logger.debug "skip to fetch feed(#{url}). the interval time does not spent."
      return
    end

    feed_content = fetch_feed_content!
    if feed_content[:modified?]
      logger.info "fetched a feed(#{url})."
      self.etag = feed_content[:etag]
      self.articles = build_articles!(feed_content[:body])
    else
      logger.info "try to fetch feed(#{url}). but it is not modified."
    end
  end

  private

    def fetch_interval_spent?
      return true if fetched_at.blank?

      (Time.zone.now - fetched_at) > FETCH_INTERVAL.seconds
    end

    def fetch_feed_content!
      begin
        feed = Feeds::Fetcher.fetch!(url, etag: etag)
      rescue SocketError, URI::Error => e
        raise FeedError, "failed to fetch feed(#{url}). #{e}"
      else
        self.fetched_at = Time.zone.now
      end
      feed
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
end
