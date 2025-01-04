class AddRaceBirthDateWeigthIdentificationSpayedOrNeuteredToPets < ActiveRecord::Migration[7.1]
  def change
    add_column :pets, :races, :string
    add_column :pets, :birthday, :date
    add_column :pets, :identification, :string
    add_column :pets, :spayed_neutered, :string
  end
end
