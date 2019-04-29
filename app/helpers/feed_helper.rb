module FeedHelper
  def feed_channel_link(feed)
    link_to feed.channel_title, feed.channel_url, target: "_blank", rel: "noopener"
  end
end
