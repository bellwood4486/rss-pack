class FeedsController < ApplicationController
  before_action :set_pack, only: %i[new create]
  before_action :set_feed, only: %i[show destroy]

  def new
    @feed_channel = Feeds::FeedChannel.new
  end

  def show
  end

  def create
    @feed_channel = Feeds::FeedChannel.new(feed_channel_params)
    render :new and return if @feed_channel.invalid?

    @feeds = Feed.discover!(@feed_channel.url)
    flash.now.alert = "フィードが見つかりませんでした" if @feeds.blank?
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

    def feed_channel_params
      params.require(:feeds_feed_channel).permit(:url)
    end
end
