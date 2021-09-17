class AddCategoryToFoodItem < ActiveRecord::Migration[6.1]
  def change
    add_column :fooditems, :category, :string
  end
end
