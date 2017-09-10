class AddRssRefreshedAtToFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :feeds, :rss_refreshed_at, :datetime
  end
end
