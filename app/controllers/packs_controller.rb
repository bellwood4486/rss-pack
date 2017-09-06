class PacksController < ApplicationController
  before_action :load_pack, only: %i(show)

  def show
  end

  def rss
    pack = Pack.find_by(token: params[:token])
  end

  private

  def load_pack
    @pack = Pack.find(params[:id])
  end
end
