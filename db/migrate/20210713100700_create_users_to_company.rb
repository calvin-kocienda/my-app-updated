class CreateUsersToCompany < ActiveRecord::Migration[6.1]
  def change
    create_table :users_to_companies do |t|
      t.integer :userid
      t.string :companyname

      t.timestamps
    end
  end
end
