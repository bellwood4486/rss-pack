class FeedsController < ApplicationController
  def index
    @feeds = Feed.all
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.new(feed_create_params)
    if @feed.save
      redirect_to feeds_path
    else
      render :new
    end
  end

  private

  def feed_create_params
    params.require(:feed).permit(:url)
  end
end
