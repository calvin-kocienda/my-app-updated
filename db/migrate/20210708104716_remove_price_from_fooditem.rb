class RemovePriceFromFooditem < ActiveRecord::Migration[6.1]
  def change
    remove_column :fooditems, :price, :integer
  end
end
