class Subscription < ApplicationRecord
  belongs_to :pack
  belongs_to :feed

  def unread_articles!
    feed.reload_articles
    articles = feed.articles.order(:published_at)
    articles = articles.published_since(read_timestamp) if read_timestamp.present?
    if articles.present?
      unless update(read_timestamp: articles.last.published_at)
        # TODO: ログに書く
      end
    end
    articles
  end
end
