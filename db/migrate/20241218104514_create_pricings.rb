class CreatePricings < ActiveRecord::Migration[7.1]
  def change
    create_table :pricings do |t|
      t.string :specialty

      t.timestamps
    end
  end
end
