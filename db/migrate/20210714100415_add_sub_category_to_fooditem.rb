class AddSubCategoryToFooditem < ActiveRecord::Migration[6.1]
  def change
    add_column :fooditems, :subcategory, :string
  end
end
