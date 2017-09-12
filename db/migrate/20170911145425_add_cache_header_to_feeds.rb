class AddCacheHeaderToFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :feeds, :etag, :string
    add_column :feeds, :last_modified, :string
  end
end
