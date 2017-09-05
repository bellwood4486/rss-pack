class CreatePacks < ActiveRecord::Migration[5.1]
  def change
    create_table :packs do |t|
      t.string :token
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
