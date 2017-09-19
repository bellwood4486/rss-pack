# frozen_string_literal: true

class CreateFeedsPacks < ActiveRecord::Migration[5.1]
  def change
    create_table :feeds_packs, id: false do |t|
      t.belongs_to :feed, index: true
      t.belongs_to :pack, index: true
    end
  end
end
