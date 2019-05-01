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

    content = fetch_content!
    if content[:modified?]
      logger.info "fetched a feed(#{url})."
      assign_attributes(etag: content[:etag], **parse_content!(content[:body]))
    else
      logger.info "try to fetch feed(#{url}). but it is not modified."
    end
  end

  private

    def fetch_interval_spent?
      return true if fetched_at.blank?

      (Time.zone.now - fetched_at) > FETCH_INTERVAL.seconds
    end

    def fetch_content!
      begin
        feed = Feeds::Fetcher.fetch!(url, etag: etag)
      rescue SocketError, URI::Error => e
        raise FeedError, "failed to fetch feed(#{url}). #{e}"
      else
        self.fetched_at = Time.zone.now
      end
      feed
    end

    def parse_content!(feed_content)
      begin
        rss_feed = RSS::Parser.parse(feed_content)
      rescue RSS::InvalidRSSError
        rss_feed = RSS::Parser.parse(feed_content, false)
      end

      case rss_feed
      when RSS::RDF # for RSS 1.0
        parse_rdf_feed(rss_feed)
      when RSS::Rss # for RSS 0.9x/2.0
        parse_rss_feed(rss_feed)
      when RSS::Atom::Feed # for Atom
        parse_atom_feed(rss_feed)
      else
        raise FeedError, "unsupport feed type. feed: #{rss_feed}"
      end
    end

    def parse_rdf_feed(rdf_feed)
      parse_rdf_or_rss_feed(rdf_feed.channel, rdf_feed.items)
    end

    def parse_rss_feed(rss_feed)
      parse_rdf_or_rss_feed(rss_feed.channel, rss_feed.channel.items)
    end

    def parse_rdf_or_rss_feed(channel, items)
      articles = items.map do |item|
        Article.new do |a|
          a.title = item.title ||= "No title"
          a.link = item.link
          a.published_at = item.date
        end
      end

      {
        channel_title: channel.title,
        channel_url: channel.link,
        channel_description: channel&.description,
        articles: articles,
      }
    end

    def parse_atom_feed(atom_feed)
      articles = atom_feed.entries.map do |entry|
        Article.new do |a|
          a.title = entry.title.content ||= "No title"
          a.link = entry.link.href
          a.published_at = entry.published.content
        end
      end

      {
        channel_title: atom_feed.title.content,
        channel_url: atom_feed.links.find {|l| l.type == "text/html" }.href,
        channel_description: atom_feed.subtitle&.content,
        articles: articles,
      }
    end
end
