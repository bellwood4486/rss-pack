class RenameRssRefreshedAtOfFeeds < ActiveRecord::Migration[5.1]
  def change
    rename_column :feeds, :rss_refreshed_at, :refreshed_at
  end
end
