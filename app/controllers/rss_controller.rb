class RssController < ApplicationController
  def show
    pack = Pack.find_by(token: params[:id])
    pack.refresh_rss_content
    render xml: pack.rss_content.to_s if pack.save
  end
end
