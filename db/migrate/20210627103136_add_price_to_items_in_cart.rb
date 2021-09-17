class AddPriceToItemsInCart < ActiveRecord::Migration[6.1]
  def change
    add_column :items_in_carts, :price, :decimal
  end
end
