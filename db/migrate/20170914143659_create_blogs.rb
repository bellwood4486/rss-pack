class CreateBlogs < ActiveRecord::Migration[5.1]
  def change
    create_table :blogs do |t|
      t.string :url
      t.string :title
      t.references :pack, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
