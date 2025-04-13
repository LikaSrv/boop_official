class AddProSignupTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :pro_signup_token, :string
  end
end
