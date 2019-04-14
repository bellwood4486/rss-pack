class Pack < ApplicationRecord
  has_many :feeds, dependent: :destroy
end
