class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamp :start_time

      t.timestamps
    end
  end
end
