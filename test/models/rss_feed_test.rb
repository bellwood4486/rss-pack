# == Schema Information
#
# Table name: rss_feeds
#
#  id           :integer          not null, primary key
#  url          :string
#  content      :text
#  refreshed_at :datetime
#  etag         :string
#  blog_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_type :string
#  title        :string
#

require 'test_helper'

class RssFeedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
