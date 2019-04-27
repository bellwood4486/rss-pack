module Feeds
  class FeedSource
    include ActiveModel::Model

    attr_accessor :url

    validates :url, presence: true

    def discover_and_save
      self.discover.select(&:save)
    end

    def discover
      Feeds::Fetcher.discover(url).map do |discovered|
        feed = Feed.find_or_initialize_by(url: discovered[:url],
                                          mime_type: discovered[:mime_type])
        # タイトルは常に最新のものを使う
        feed.title = discovered[:title] || "NO_NAME"
        feed.fetch
        feed
      end
    end
  end
end
