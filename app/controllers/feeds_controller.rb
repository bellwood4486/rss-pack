class FeedsController < ApplicationController
  before_action :set_pack, only: %i[new create]
  before_action :set_feed, only: %i[show destroy]

  def new
    @feed_source = Feeds::FeedSource.new
  end

  def show
  end

  def create
    @feed_source = Feeds::FeedSource.new(feed_source_params)
    render :new and return if @feed_source.invalid?

    @feed = @feed_source.discover
    unless @feed&.save
      flash.now.alert = "フィードが見つかりませんでした"
    end
    # TODO: Ajax化してもよいかも。要検討
    render :new
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
      @feed = Feed.find(params[:id])
    end

    def feed_source_params
      params.require(:feeds_feed_source).permit(:url)
    end
end
