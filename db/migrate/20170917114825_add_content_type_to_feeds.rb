class AddContentTypeToFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :feeds, :content_type, :string
  end
end
