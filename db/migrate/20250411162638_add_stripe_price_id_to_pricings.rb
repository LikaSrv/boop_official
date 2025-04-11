class AddStripePriceIdToPricings < ActiveRecord::Migration[7.1]
  def change
    add_column :pricings, :stripe_price_id, :string
  end
end
