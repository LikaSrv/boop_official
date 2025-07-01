class RemoveUniqueIndexFromPostsTitle < ActiveRecord::Migration[7.1]
  def change
    remove_index :posts, :title
  end
end
