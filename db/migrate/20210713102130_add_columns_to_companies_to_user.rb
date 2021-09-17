class AddColumnsToCompaniesToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :companies_to_users, :user_id, :integer
    add_column :companies_to_users, :company_id, :integer
  end
end
