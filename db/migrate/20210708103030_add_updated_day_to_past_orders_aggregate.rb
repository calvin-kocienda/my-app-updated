class AddUpdatedDayToPastOrdersAggregate < ActiveRecord::Migration[6.1]
  def change
    add_column :past_orders_aggregates, :updated_day, :integer
  end
end
