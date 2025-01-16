class AddPhotoToPetAlert < ActiveRecord::Migration[7.1]
  def change
    add_column :pet_alerts, :photo_url, :string
  end
end
