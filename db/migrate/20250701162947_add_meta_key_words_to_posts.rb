class AddMetaKeyWordsToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :meta_keywords, :string, array: true, default: []
  end
end
