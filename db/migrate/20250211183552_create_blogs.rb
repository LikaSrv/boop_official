class CreateBlogs < ActiveRecord::Migration[7.1]
  def change
    create_table :blogs do |t|
      t.string :title
      t.string :meta_title
      t.string :text1
      t.string :photo1
      t.string :text2
      t.string :photo2
      t.string :text3
      t.string :photo3

      t.timestamps
    end
  end
end
