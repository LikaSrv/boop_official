class AddPriceToPaymentPlan < ActiveRecord::Migration[7.1]
  def change
    add_monetize :payment_plans, :price, currency: { present: false }
  end
end
