class User < ApplicationRecord
  has_many :feeds, dependent: :destroy
end
