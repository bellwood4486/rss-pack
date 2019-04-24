require "rss"

class Pack < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_many :subscriptions, dependent: :destroy
  has_many :feeds, through: :subscriptions
  has_secure_token

  def rss_url
    pack_rss_url(token)
  end

  def reload_rss!
    update!(rss_content: create_rss(unread_articles))
  end

  private

    def unread_articles
      subscriptions.includes(:feed).inject([]) do |articles, subscription|
        articles.concat(subscription.unread_articles)
      end
    end

    def create_rss(articles)
      rss = RSS::Maker.make("2.0") do |maker|
        maker.channel.title = "#{name} | RssPack"
        maker.channel.link = pack_url(self)
        maker.channel.description = "このフィードはRssPackで生成されています"
        maker.items.do_sort = true
        articles.each do |article|
          maker.items.new_item do |item|
            item.title = article.title
            item.link = article.link
            item.date = article.published_at.iso8601
          end
        end
      end
      rss.to_s
    end
end
