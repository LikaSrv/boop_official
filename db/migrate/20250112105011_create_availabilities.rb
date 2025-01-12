class CreateAvailabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :availabilities do |t|
      t.references :professional, null: false, foreign_key: true
      t.datetime :start_time
      t.boolean :status

      t.timestamps
    end
  end
end
