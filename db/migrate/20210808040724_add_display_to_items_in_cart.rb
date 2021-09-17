class AddDisplayToItemsInCart < ActiveRecord::Migration[6.1]
  def change
    add_column :items_in_carts, :display, :boolean
  end
end
