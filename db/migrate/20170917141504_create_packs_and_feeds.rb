# frozen_string_literal: true

class CreatePacksAndFeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :packs_and_feeds, id: false do |t|
      t.belongs_to :pack, index: true
      t.belongs_to :feed, index: true
    end
  end
end
