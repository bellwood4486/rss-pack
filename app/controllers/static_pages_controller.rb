class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @feeds = Feed.where(user: current_user)
    end
  end
end
