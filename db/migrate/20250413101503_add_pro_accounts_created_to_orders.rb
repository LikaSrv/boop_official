class AddProAccountsCreatedToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :pro_accounts_created, :integer
  end
end
