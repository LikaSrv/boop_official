class AddEmailToShelters < ActiveRecord::Migration[7.1]
  def change
    add_column :shelters, :email, :string
  end
end
