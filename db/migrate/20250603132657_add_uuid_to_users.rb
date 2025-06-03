class AddUuidToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :uuid, :string
  end
end
