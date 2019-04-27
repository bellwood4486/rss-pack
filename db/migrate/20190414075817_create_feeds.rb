class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.string :url, null: false
      t.string :title, null: false
      t.string :mime_type, null: false
      t.string :etag
      t.datetime :fetched_at

      t.timestamps
    end
  end
end
