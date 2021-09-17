class AddCompanyToFooditem < ActiveRecord::Migration[6.1]
  def change
    add_column :fooditems, :company, :string
  end
end
