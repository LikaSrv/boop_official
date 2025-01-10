class AddCapacityToProfessional < ActiveRecord::Migration[7.1]
  def change
    add_column :professionals, :capacity, :integer
  end
end
