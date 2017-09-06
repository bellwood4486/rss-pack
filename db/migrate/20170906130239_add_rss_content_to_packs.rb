class AddRssContentToPacks < ActiveRecord::Migration[5.1]
  def change
    add_column :packs, :rss_content, :text
  end
end
