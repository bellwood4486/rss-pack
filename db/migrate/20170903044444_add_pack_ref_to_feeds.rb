class AddPackRefToFeeds < ActiveRecord::Migration[5.1]
  def change
    add_reference :feeds, :pack, foreign_key: true
  end
end
