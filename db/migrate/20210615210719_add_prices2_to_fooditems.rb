class AddPrices2ToFooditems < ActiveRecord::Migration[6.1]
  def change
    add_column :fooditems, :price2, :decimal
  end
end
