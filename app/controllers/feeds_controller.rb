# frozen_string_literal: true

class FeedsController < ApplicationController
  before_action :load_feed, only: %i[destroy]

  def index
    @feeds = current_user.feeds
  end

  def discover
    @feed_source = FeedSource.new
  end

  def select
    @feed_source = FeedSource.new(url: params[:feed_source][:url])
    if @feed_source.valid?
      @feeds = Feed.discover(@feed_source.url)
      if @feeds.blank?
        flash[:error] = 'フィードが見つかりませんでした。URLを見直してみてください。'
        render :discover
        return
      end
    else
      render :discover
    end
  end

  def create
    @feed = current_user.feeds.build(feed_create_params)
    @feed.packs << current_user.packs.first # :TODO 決め打ちをあとでなおす
    @feed.refresh
    if @feed.save
      redirect_to feeds_url, notice: '追加しました'
    else
      render :select
    end
  end

  def destroy
    @feed.destroy
    redirect_to feeds_url, notice: '削除しました'
  end

  private

  def feed_create_params
    params.require(:feed).permit(:url, :title, :content_type)
  end

  def load_feed
    @feed = Feed.find(params[:id])
  end
end
