class CreatePastOrdersUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :past_orders_users do |t|
      t.integer :userid
      t.integer :itemid
      t.integer :itemcount
      t.integer :totalcost

      t.timestamps
    end
  end
end
