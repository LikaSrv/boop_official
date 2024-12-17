class RemoveShelterFromPets < ActiveRecord::Migration[7.1]
  def change
    remove_column :pets, :shelter
  end
end
