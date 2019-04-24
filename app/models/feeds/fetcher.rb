require "net/http"
require "open-uri"

module Feeds
  class Fetcher
    RSS_MIME_TYPES = %w[
      application/rss+xml
      application/atom+xml
    ].freeze

    class << self
      def discover(url)
        charset = nil
        begin
          html = URI.parse(url).open do |f|
            charset = f.charset
            f.read
          end
        rescue Errno::ENOENT, OpenURI::HTTPError, NoMethodError
          return []
        end

        parse_rss_feeds(html, charset)
      end

      def parse_rss_feeds(html_body, charset)
        html_doc = Nokogiri::HTML.parse(html_body, nil, charset)
        rss_feeds = []
        RSS_MIME_TYPES.each do |rss_mime_type|
          html_doc.xpath("//link[@rel='alternate' and @type='#{rss_mime_type}']").map do |link|
            rss_feeds << {
              content_type: link.attributes["type"]&.value,
              title: link.attributes["title"]&.value,
              url: link.attributes["href"]&.value,
            }
          end
        end
        rss_feeds
      end

      def fetch!(url, etag: nil)
        uri = URI(url)
        raise URI::InvalidURIError, "invalid url: #{url}" unless uri.respond_to? :request_uri

        req = Net::HTTP::Get.new(uri)
        req["If-None-Match"] = etag
        res = Net::HTTP.start(uri.host, uri.port,
                              use_ssl: uri.scheme == "https") do |http|
          http.open_timeout = 5
          http.read_timeout = 10
          http.request(req)
        end

        result = { modified?: false, etag: nil, body: nil }
        case res
        when Net::HTTPSuccess
          result[:modified?] = true
          result[:etag] = sanitize_etag(res["Etag"])
          result[:body] = res.body.force_encoding("UTF-8")
        end
        result
      end

      def sanitize_etag(etag)
        return if etag.blank?

        # Apache 2.4のmod_deflateのバグにより、Etagに'-gzip'というサフィックスが付けられてしまう場合があるため削る
        etag.gsub(/-gzip"$/, '"')
      end
    end
  end
end
