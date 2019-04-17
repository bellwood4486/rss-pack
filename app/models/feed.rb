class Feed < ApplicationRecord
  has_many :subscriptions, dependent: :nullify

  def self.discover(url)
    Feeds::Fetcher.discover(url).map do |discovered|
      feed = Feed.find_or_initialize_by(url: discovered[:url],
                                        content_type: discovered[:content_type])
      # タイトルは常に最新のものを使う
      feed.title = discovered[:title] || "NO_NAME"
      feed
    end
  end

  def self.discover_and_save(url)
    discover(url).select(&:save)
  end
end
