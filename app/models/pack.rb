class Pack < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_many :feeds, dependent: :destroy
  has_secure_token

  def rss_url
    pack_rss_url(token)
  end
end
