# == Schema Information
#
# Table name: feeds
#
#  id           :integer          not null, primary key
#  url          :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content      :text
#  refreshed_at :datetime
#  etag         :string
#  content_type :string
#  user_id      :integer
#

require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
