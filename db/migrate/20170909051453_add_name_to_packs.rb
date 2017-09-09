class AddNameToPacks < ActiveRecord::Migration[5.1]
  def change
    add_column :packs, :name, :string
  end
end
