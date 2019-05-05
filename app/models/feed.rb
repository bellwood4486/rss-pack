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
      assign_attributes(etag: content[:etag], **feed_parser.parse_content!(content[:body]))
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

    def feed_parser
      Feeds::Parser.new
    end
end
