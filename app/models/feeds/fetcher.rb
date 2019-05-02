require "net/http"
require "open-uri"

module Feeds
  class Fetcher
    class << self
      def discover(url)
        page = MetaInspector.new(url)
      rescue MetaInspector::Error => e
        Rails.logger.info "unable to fetch the page (url:#{url}). #{e}"
        nil
      else
        page.feed
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
