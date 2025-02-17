class CreateClosingHours < ActiveRecord::Migration[7.1]
  def change
    create_table :closing_hours do |t|
      t.references :professional, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
