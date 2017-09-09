# == Schema Information
#
# Table name: packs
#
#  id               :integer          not null, primary key
#  rss_token        :string
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  rss_content      :text
#  rss_refreshed_at :datetime
#  name             :string
#

require 'test_helper'

class PackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
