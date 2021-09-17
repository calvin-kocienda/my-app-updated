class AddShowToFoodItems < ActiveRecord::Migration[6.1]
  def change
    add_column :fooditems, :show, :boolean
  end
end
