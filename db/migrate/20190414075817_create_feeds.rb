class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.references :pack, foreign_key: true, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
