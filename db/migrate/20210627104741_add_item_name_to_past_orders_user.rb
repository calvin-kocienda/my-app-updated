class AddItemNameToPastOrdersUser < ActiveRecord::Migration[6.1]
  def change
    add_column :past_orders_users, :itemname, :string
  end
end
