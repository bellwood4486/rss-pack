class Subscription < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :pack
  belongs_to :feed

  def unread_articles
    begin
      feed.fetch_and_save!
    rescue Feed::FeedError => e
      update_message!("未読記事を取得ができませんでした。詳細：#{e}")
      return [subscribe_error_article("未読記事の取得失敗", e)]
    else
      clear_message!
    end

    articles = feed.articles.order(:published_at)
    articles = articles.published_since(read_timestamp) if read_timestamp.present?
    update!(read_timestamp: articles.last.published_at) if articles.present?
    articles.to_a
  end

  private

    def subscribe_error_article(error_summary, error)
      Article.new do |a|
        a.title = "[RSSPACKからのお知らせ]#{error_summary}"
        a.link = pack_subscription_url(pack, self)
        a.summary = error.message
        a.published_at = Time.zone.now
      end
    end

    def update_message!(message)
      update!(messaged_at: Time.zone.now, message: message)
    end

    def clear_message!
      update!(messaged_at: nil, message: nil)
    end
end
