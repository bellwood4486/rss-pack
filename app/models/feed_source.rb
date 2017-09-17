# frozen_string_literal: true

class FeedSource
  include ActiveModel::Model

  attr_accessor :url
  validates :url, presence: true
end
