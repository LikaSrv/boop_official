class AddProSignupTokenToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :pro_signup_token, :string
  end
end
