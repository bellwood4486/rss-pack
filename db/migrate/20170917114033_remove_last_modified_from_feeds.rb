class RemoveLastModifiedFromFeeds < ActiveRecord::Migration[5.1]
  def change
    remove_column :feeds, :last_modified, :string
  end
end
