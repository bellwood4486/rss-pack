module Feeds
  class FeedSource
    include ActiveModel::Model

    attr_accessor :url

    validates :url, presence: true

    def discover
      feed_url = Feeds::Fetcher.discover(url)
      return nil if feed_url.blank?

      feed = Feed.find_or_initialize_by(url: feed_url)
      feed.fetch
      feed
    end
  end
end
