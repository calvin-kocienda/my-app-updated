class AddPriceToFooditem < ActiveRecord::Migration[6.1]
  def change
    add_column :fooditems, :price, :integer
  end
end
