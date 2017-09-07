class AddContentToFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :feeds, :content, :text
  end
end
