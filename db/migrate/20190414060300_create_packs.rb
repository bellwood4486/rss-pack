class CreatePacks < ActiveRecord::Migration[5.2]
  def change
    create_table :packs do |t|
      t.references :user, foreign_key: true, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
