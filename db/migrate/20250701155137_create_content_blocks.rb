class CreateContentBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :content_blocks do |t|
      t.integer :position, null: false
      t.text :body, null: false
      t.references :post, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
