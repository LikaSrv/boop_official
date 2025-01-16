class AddPhotoUrLtoProfessional < ActiveRecord::Migration[7.1]
  def change
    add_column :professionals, :photo_url, :string
  end
end
