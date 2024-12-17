class AddShelterToPets < ActiveRecord::Migration[7.1]
  def change
    add_column :pets, :shelter, :string
  end
end
