class CreateRssFeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :rss_feeds do |t|
      t.string :url
      t.text :content
      t.datetime :refreshed_at
      t.string :etag
      t.references :blog, foreign_key: true

      t.timestamps
    end
  end
end
