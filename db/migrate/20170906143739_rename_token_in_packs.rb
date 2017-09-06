class RenameTokenInPacks < ActiveRecord::Migration[5.1]
  def change
    rename_column :packs, :token, :rss_token
  end
end
