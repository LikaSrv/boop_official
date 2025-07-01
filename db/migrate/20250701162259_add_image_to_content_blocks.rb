class AddImageToContentBlocks < ActiveRecord::Migration[7.1]
  def change
    add_column :content_blocks, :image, :string
  end
end
