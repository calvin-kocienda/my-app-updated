class AddAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :isadmin, :integer
  end
end
