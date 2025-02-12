class AddIntroAndConclusionToBlog < ActiveRecord::Migration[7.1]
  def change
    add_column :blogs, :intro, :string
    add_column :blogs, :conclusion, :string
  end
end
