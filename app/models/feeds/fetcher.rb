# frozen_string_literal: true

require 'net/http'

module Feeds
  class Fetcher
    def self.fetch(url, etag: nil, response_body_if_not_modified: nil)
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
