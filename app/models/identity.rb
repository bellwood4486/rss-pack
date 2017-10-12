# frozen_string_literal: true

class Identity
  include ActiveModel::Model

  attr_accessor :email
  attr_accessor :password
  validates :email, presence: true
  validates :password, presence: true
end
