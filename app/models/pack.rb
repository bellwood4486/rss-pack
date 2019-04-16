class Pack < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_many :subscriptions, dependent: :destroy
  has_many :feeds, through: :subscriptions
  has_secure_token

  def rss_url
    pack_rss_url(token)
  end
end
