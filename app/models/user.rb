class User < ApplicationRecord
  has_many :packs, dependent: :destroy
  has_secure_password
  before_save :downcase_email

  private

  def downcase_email
    email.downcase!
  end
end
