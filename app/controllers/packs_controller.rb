# frozen_string_literal: true

class PacksController < ApplicationController
  def rss
    (pack = Pack.find_by(rss_token: params[:token])) || not_found
    pack.refresh!(rss_url)
    render xml: pack.rss_content.to_s
  end

end
