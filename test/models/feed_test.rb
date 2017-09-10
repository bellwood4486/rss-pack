# == Schema Information
#
# Table name: feeds
#
#  id               :integer          not null, primary key
#  url              :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pack_id          :integer
#  content          :text
#  user_id          :integer
#  rss_refreshed_at :datetime
#

require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
