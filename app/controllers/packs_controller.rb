class PacksController < ApplicationController
  before_action :set_pack, only: %i[show edit update destroy]

  def index
    @packs = current_user.packs
  end

  def show
  end

  def new
    @pack = Pack.new
  end

  def edit
  end

  def create
    @pack = current_user.packs.build(pack_params)
    if @pack.save
      redirect_to @pack, notice: "パックを作成しました"
    else
      render :new
    end
  end

  def update
    if @pack.update(pack_params)
      redirect_to @pack, notice: "パックを更新しました"
    else
      render :edit
    end
  end

  def destroy
    @pack.destroy!
    redirect_to packs_url, notice: "パックを削除しました"
  end

  private

    def set_pack
      @pack = current_user.packs.find(params[:id])
    end

    def pack_params
      params.require(:pack).permit(:name)
    end
end
