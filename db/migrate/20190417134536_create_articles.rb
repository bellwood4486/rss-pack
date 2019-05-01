class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.references :feed, foreign_key: true, null: false
      t.string :title, null: false
      t.string :link, null: false
      t.datetime :published_at, null: false
      t.text :summary

      t.timestamps
    end
  end
end
