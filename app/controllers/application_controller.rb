class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
