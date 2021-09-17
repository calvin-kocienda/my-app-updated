class AddCompanyNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :companyname, :string
  end
end
