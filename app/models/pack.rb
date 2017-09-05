class Pack < ApplicationRecord
  belongs_to :user
  has_many :feeds

  def self.new_token
    SecureRandom.urlsafe_base64
  end
end
