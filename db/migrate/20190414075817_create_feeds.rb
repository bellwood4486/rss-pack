class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.string :url, null: false
      t.string :title, null: false
      t.string :mime_type, null: false
      t.string :etag
      t.datetime :fetched_at
      t.string :channel_title, null: false
      t.string :channel_url, null: false
      t.text :channel_description

      t.timestamps
    end
  end
end
