class PacksController < ApplicationController
  before_action :load_pack, only: %i(show)

  def show
  end

  private

  def load_pack
    @pack = Pack.find(params[:id])
  end
end
