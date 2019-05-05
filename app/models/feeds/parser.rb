require "rss"

module Feeds
  class Parser
    def initialize
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
        raise Feed::FeedError, "unsupport feed type. feed: #{rss_feed}"
      end
    end

    private

      def parse_rdf_feed(rdf_feed)
        parse_rdf_or_rss_feed(rdf_feed.channel, rdf_feed.items)
      end

      def parse_rss_feed(rss_feed)
        parse_rdf_or_rss_feed(rss_feed.channel, rss_feed.channel.items)
      end

      def parse_rdf_or_rss_feed(channel, items)
        articles = items.select {|item| item.date.present? }.map do |item|
          Article.new do |a|
            a.title = item.title ||= "No title"
            a.link = item.link ||= "No link"
            a.published_at = item.date
            a.summary = item.description
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
            a.link = entry.link&.href ||= "No link"
            a.published_at = entry.published&.content || entry.updated.content
            a.summary = entry.summary&.content
          end
        end

        {
          channel_title: atom_feed.title.content,
          channel_url: channel_link_of(atom_feed),
          channel_description: atom_feed.subtitle&.content,
          articles: articles,
        }
      end

      def channel_link_of(atom_feed)
        case atom_feed.links.size
        when 0
          "No link"
        when 1
          atom_feed.links.first.href
        else
          (atom_feed.links.find {|l| l.type == "text/html" } || atom_feed.links.first).href
        end
      end
  end
end
