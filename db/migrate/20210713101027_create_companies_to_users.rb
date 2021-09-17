class CreateCompaniesToUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :companies_to_users do |t|
      t.integer :userid
      t.string :companyname

      t.timestamps
    end
  end
end
