class Subscription < ApplicationRecord
  belongs_to :pack
  belongs_to :feed
end
