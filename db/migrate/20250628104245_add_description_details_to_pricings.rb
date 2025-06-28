class AddDescriptionDetailsToPricings < ActiveRecord::Migration[7.1]
  def change
    add_column :pricings, :description_details, :string, array: true, default: []
  end
end
