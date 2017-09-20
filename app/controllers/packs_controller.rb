class PacksController < ApplicationController

  def rss
    pack = Pack.find_by(rss_token: params[:token])
    pack.refresh!
    render xml: pack.rss_content.to_s
  end

  private

  def load_pack
    @pack = Pack.find(params[:id])
  end
end
