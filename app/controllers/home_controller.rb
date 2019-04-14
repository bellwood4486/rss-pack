class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :require_guest

  def index
  end

  private

    def require_guest
      redirect_to packs_url if user_signed_in?
    end
end
