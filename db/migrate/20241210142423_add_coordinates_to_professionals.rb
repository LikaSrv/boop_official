class AddCoordinatesToProfessionals < ActiveRecord::Migration[7.1]
  def change
    add_column :professionals, :latitude, :float
    add_column :professionals, :longitude, :float
  end
end
