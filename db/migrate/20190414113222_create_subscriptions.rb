class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :pack, foreign_key: true
      t.references :feed, foreign_key: true
      t.datetime :read_timestamp
      t.text :message
      t.datetime :messaged_at

      t.timestamps
    end
  end
end
