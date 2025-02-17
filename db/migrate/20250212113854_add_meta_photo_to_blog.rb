class AddMetaPhotoToBlog < ActiveRecord::Migration[7.1]
  def change
    add_column :blogs, :introPhoto, :string
  end
end
