class User < ApplicationRecord
  has_many :packs, dependent: :destroy
end
