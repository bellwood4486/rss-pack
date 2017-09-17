class RemovePackRefFromFeeds < ActiveRecord::Migration[5.1]
  def change
    remove_reference :feeds, :pack, foreign_key: true
  end
end
