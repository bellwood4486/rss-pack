class Pack < ApplicationRecord
  belongs_to :user
  has_many :feeds
  before_create :create_pack_rss_token

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  private

  def create_pack_rss_token
    self.token = Pack.new_token
  end
end
