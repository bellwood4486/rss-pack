class PacksController < ApplicationController
  before_action :load_pack, only: %i(show)

  def show
  end

  def create
    @pack = current_user.packs.build(name: 'New Pack')
    if @pack.save
      flash[:success] = 'パックを作成しました!'
    else
      flash[:danger] = '作成に失敗しました...'
    end
    redirect_to root_url
  end

  private

  def load_pack
    @pack = Pack.find(params[:id])
  end
end
