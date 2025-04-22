class UpdatePictureToMultiplePicturesPro < ActiveRecord::Migration[7.1]
  def change
    remove_column :professionals, :photo_url, :string
    add_column :professionals, :photos_url, :jsonb, default: -> { "'[]'::jsonb" }
  end
end
