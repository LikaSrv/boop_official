class CreateNationalDaysOffs < ActiveRecord::Migration[7.1]
  def change
    create_table :national_days_offs do |t|
      t.string :name
      t.date :date

      t.timestamps
    end
  end
end
