# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string
#

class User < ApplicationRecord
  has_many :packs, dependent: :destroy
  has_many :feeds, dependent: :destroy
  has_secure_password
  before_save :downcase_email
  validates :email, presence: true, uniqueness: true

  private

  def downcase_email
    email.downcase!
  end
end
