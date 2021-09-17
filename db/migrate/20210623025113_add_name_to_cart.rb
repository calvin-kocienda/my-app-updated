class AddNameToCart < ActiveRecord::Migration[6.1]
  def change
    add_column :items_in_carts, :itemname, :string
  end
end
