class RssController < ApplicationController
  def show
    pack = Pack.find_by(rss_token: params[:id])
    pack.refresh_rss
    render xml: pack.rss_content.to_s
  end
end
