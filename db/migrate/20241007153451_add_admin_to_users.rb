class AddAdminToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin, :boolean
  end
end
