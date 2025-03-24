class AddCapacityToPricings < ActiveRecord::Migration[7.1]
  def change
    add_column :pricings, :capacity, :integer
  end
end
