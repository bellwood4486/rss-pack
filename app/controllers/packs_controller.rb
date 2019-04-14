class PacksController < ApplicationController
  before_action :set_pack, only: [:show, :edit, :update, :destroy]

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
    @pack = Pack.new(pack_params)
    if @pack.save
      redirect_to @pack, notice: "Pack was successfully created."
    else
      render :new
    end
  end

  def update
    if @pack.update(pack_params)
      redirect_to @pack, notice: "Pack was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @pack.destroy!
    redirect_to packs_url, notice: "Pack was successfully destroyed."
  end

  private

    def set_pack
      @pack = Pack.find(params[:id])
    end

    def pack_params
      params.require(:pack).permit(:name)
    end
end
