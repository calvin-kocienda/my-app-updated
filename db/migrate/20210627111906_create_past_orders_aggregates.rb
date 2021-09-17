class CreatePastOrdersAggregates < ActiveRecord::Migration[6.1]
  def change
    create_table :past_orders_aggregates do |t|
      t.integer :userid
      t.string :username
      t.string :itemname
      t.integer :itemcount

      t.timestamps
    end
  end
end
