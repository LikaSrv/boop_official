class DeleteSpecialtyFromPricing < ActiveRecord::Migration[7.1]
  def change
    remove_column :pricings, :specialty
  end
end
