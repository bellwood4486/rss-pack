class AddContentTypeToRssFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :rss_feeds, :content_type, :string
  end
end
