class AddTitleAndDescriptionToPricing < ActiveRecord::Migration[7.1]
  def change
    add_column :pricings, :title, :string
    add_column :pricings, :description, :string
  end
end
