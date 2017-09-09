class StaticPagesController < ApplicationController
  def home
    @packs = current_user.packs if logged_in?
  end
end
