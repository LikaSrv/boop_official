class CreateOpeningHours < ActiveRecord::Migration[7.1]
  def change
    create_table :opening_hours do |t|
      t.integer :day_of_week
      t.time :open_time_morning
      t.time :close_time_morning
      t.boolean :closed
      t.references :professional, null: false, foreign_key: true

      t.timestamps
    end
  end
end
