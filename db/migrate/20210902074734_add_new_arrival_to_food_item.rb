class AddNewArrivalToFoodItem < ActiveRecord::Migration[6.1]
  def change
    add_column :fooditems, :newarrival, :boolean
  end
end
