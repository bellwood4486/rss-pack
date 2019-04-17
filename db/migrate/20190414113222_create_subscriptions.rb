class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :pack, foreign_key: true
      t.references :feed, foreign_key: true

      t.timestamps
    end
  end
end
