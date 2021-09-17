class CreateTempCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :temp_carts do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :itemcount

      t.timestamps
    end
  end
end
