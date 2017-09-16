class AddTitleToRssFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :rss_feeds, :title, :string
  end
end
