class CreatePacks < ActiveRecord::Migration[5.2]
  def change
    create_table :packs do |t|
      t.references :user, foreign_key: true, null: false
      t.string :name, null: false
      t.string :token, null: false
      t.text :rss_content
      t.datetime :rss_created_at

      t.timestamps
    end

    add_index :packs, :token, unique: true
  end
end
