# frozen_string_literal: true

require 'net/http'
require 'open-uri'

module Feeds
  class Fetcher
    class << self
      def discover(url)
        charset = nil
        begin
          html = open(url) do |f|
            charset = f.charset
            f.read
          end
        rescue Errno::ENOENT, OpenURI::HTTPError
          return []
        end
        html_doc = Nokogiri::HTML.parse(html, nil, charset)
        html_doc.xpath("//link[@rel='alternate']").map do |link|
          attrs = link.attributes
          {
              content_type: attrs['type']&.value,
              title: attrs['title']&.value,
              url: attrs['href']&.value,
          }
        end
      end

      def fetch(url, etag: nil, response_body_if_not_modified: nil)
        result = { etag: nil, body: nil }
        uri = URI.parse(url)
        return result if [uri.host, uri.port, uri.scheme].any?(&:blank?)

        req = Net::HTTP::Get.new(uri.request_uri)
        req['If-None-Match'] = etag
        res = Net::HTTP.start(uri.host, uri.port,
                              use_ssl: uri.scheme == 'https') do |http|
          http.open_timeout = 5
          http.read_timeout = 10
          http.request(req)
        end

        case res
          when Net::HTTPSuccess
            result[:etag] = res['Etag']
            result[:body] = res.body.force_encoding('UTF-8')
          when Net::HTTPNotModified
            result[:etag] = etag
            result[:body] = response_body_if_not_modified
        end
        result
      end
    end
  end
end

