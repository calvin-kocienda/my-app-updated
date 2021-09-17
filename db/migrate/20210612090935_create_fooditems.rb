class CreateFooditems < ActiveRecord::Migration[6.1]
  def change
    create_table :fooditems do |t|
      t.string :item
      t.integer :count
	  t.decimal :price

      t.timestamps
    end
  end
end
