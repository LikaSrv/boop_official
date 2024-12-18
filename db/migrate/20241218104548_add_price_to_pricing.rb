class AddPriceToPricing < ActiveRecord::Migration[7.1]
  def change
    add_monetize :pricings, :price, currency: { present: false }
  end
end
