class FeedsController < ApplicationController
  before_action :set_pack
  before_action :set_feed, only: :destroy

  def index
    # TODO: オーダー
    @feeds = @pack.feeds
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = @pack.feeds.build(feed_params)
    if @feed.save
      redirect_to pack_feeds_url(@pack), notice: "フィードを追加しました"
    else
      render :new
    end
  end

  def destroy
    @feed.destroy!
    redirect_to pack_feeds_url(@pack), notice: "フィードを解除しました"
  end

  private

    def set_pack
      @pack = current_user.packs.find(params[:pack_id])
    end

    def set_feed
      @feed = @pack.feeds.find(params[:id])
    end

    def feed_params
      params.require(:feed).permit(:url)
    end
end
