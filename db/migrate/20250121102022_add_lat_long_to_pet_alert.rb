class AddLatLongToPetAlert < ActiveRecord::Migration[7.1]
  def change
    add_column :pet_alerts, :latitude, :float
    add_column :pet_alerts, :longitude, :float
  end
end
