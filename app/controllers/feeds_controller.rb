class FeedsController < ApplicationController
  before_action :load_feed, only: %i(destroy)

  def index
    @feeds = current_user.feeds
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = current_user.feeds.build(feed_create_params)
    @feed.pack = current_user.packs.first # :TODO 決め打ちをあとでなおす
    @feed.refresh_rss!
    if @feed.save
      redirect_to feeds_url, notice: '追加しました'
    else
      render :new
    end
  end

  def destroy
    @feed.destroy
    redirect_to feeds_url, notice: '削除しました'
  end

  private

  def feed_create_params
    params.require(:feed).permit(:url)
  end

  def load_feed
    @feed = Feed.find(params[:id])
  end
end
