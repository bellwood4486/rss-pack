require "rss"

class Pack < ApplicationRecord
  include Rails.application.routes.url_helpers

  RSS_CREATE_INTERVAL = ENV["RSSPACK_PACK_RSS_CREATE_INTERVAL"]&.to_i || 3600

  belongs_to :user
  has_many :subscriptions, dependent: :destroy
  has_many :feeds, through: :subscriptions
  has_secure_token

  validates :name, presence: true

  def rss_url
    pack_rss_url(token)
  end

  def reload_rss!
    return unless rss_create_interval_spent?

    update!(rss_content: create_rss(unread_articles), rss_created_at: Time.zone.now)
  end

  def next_rss_reload_time
    rss_created_at.present? ? RSS_CREATE_INTERVAL.seconds.since(rss_created_at) : nil
  end

  private

    def rss_create_interval_spent?(time = Time.zone.now)
      return true if rss_created_at.blank?

      (time - rss_created_at) > RSS_CREATE_INTERVAL.seconds
    end

    def unread_articles
      subscriptions.includes(:feed).inject([]) do |articles, subscription|
        articles.concat(subscription.unread_articles)
      end
    end

    def create_rss(articles)
      rss = RSS::Maker.make("atom") do |maker|
        write_channel_to_maker!(maker)
        maker.items.do_sort = true
        articles.each do |article|
          maker.items.new_item do |item|
            item.title = article.title
            item.link = article.link
            item.date = article.published_at.iso8601
            item.summary = article.summary
          end
        end
      end
      rss.to_xml
    end

    def write_channel_to_maker!(maker)
      maker.channel.about = rss_url
      maker.channel.title = "#{name} | RssPack"
      maker.channel.link = pack_url(self)
      maker.channel.description = "このフィードはRssPackで生成されています"
      maker.channel.author = "RssPack"
      maker.channel.date = Time.zone.now.iso8601
    end
end
