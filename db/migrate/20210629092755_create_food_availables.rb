class CreateFoodAvailables < ActiveRecord::Migration[6.1]
  def change
    create_table :food_availables do |t|
      t.string :companyname
      t.string :itemname
      t.integer :count

      t.timestamps
    end
  end
end
