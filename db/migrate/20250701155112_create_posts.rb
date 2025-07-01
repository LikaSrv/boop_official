class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :meta_title, null: false
      t.string :meta_description, null: false
      t.text :intro, null: false
      t.text :conclusion, null: false
      t.datetime :published_at, null: true
      t.timestamps
    end
    add_index :posts, :title, unique: true
    add_index :posts, :slug,  unique: true
  end
end
