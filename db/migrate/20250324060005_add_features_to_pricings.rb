class AddFeaturesToPricings < ActiveRecord::Migration[7.1]
  def change
    add_column :pricings, :features, :string, array: true, default: []
    add_column :pricings, :conclusion, :text
  end
end
