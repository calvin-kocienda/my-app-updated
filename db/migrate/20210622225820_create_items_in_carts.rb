class CreateItemsInCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :items_in_carts do |t|
      t.integer :userid
      t.integer :itemid
      t.integer :itemcount

      t.timestamps
    end
  end
end
