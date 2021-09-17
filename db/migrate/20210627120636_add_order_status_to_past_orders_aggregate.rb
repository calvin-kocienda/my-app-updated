class AddOrderStatusToPastOrdersAggregate < ActiveRecord::Migration[6.1]
  def change
    add_column :past_orders_aggregates, :status, :string
  end
end
