# frozen_string_literal: true

require 'net/http'

module Feeds
  class Fetcher
    def self.fetch(url, etag: nil, response_body_if_not_modified: nil)
      uri = URI.parse(url)
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
          { etag: res['Etag'], body: res.body.force_encoding('UTF-8') }
        when Net::HTTPNotModified
          { etag: etag, body: response_body_if_not_modified }
        else
          { etag: nil, body: nil }
      end
    end
  end
end
