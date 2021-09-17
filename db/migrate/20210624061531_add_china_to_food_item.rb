class AddChinaToFoodItem < ActiveRecord::Migration[6.1]
  def change
	add_column :fooditems, :china, :integer
  end
end
