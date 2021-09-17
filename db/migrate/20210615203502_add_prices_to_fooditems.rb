class AddPricesToFooditems < ActiveRecord::Migration[6.1]
  def change
    remove_column :fooditem, :price, :integer
  end
end
