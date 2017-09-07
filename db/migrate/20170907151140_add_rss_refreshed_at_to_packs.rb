class AddRssRefreshedAtToPacks < ActiveRecord::Migration[5.1]
  def change
    add_column :packs, :rss_refreshed_at, :datetime
  end
end
