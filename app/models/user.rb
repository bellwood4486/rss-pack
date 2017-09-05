class User < ApplicationRecord
  has_many :feeds, dependent: :destroy
  has_many :packs, dependent: :destroy
end
