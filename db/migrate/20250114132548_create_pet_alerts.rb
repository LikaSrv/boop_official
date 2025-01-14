class CreatePetAlerts < ActiveRecord::Migration[7.1]
  def change
    create_table :pet_alerts do |t|
      t.references :user, foreign_key: true
      t.string :title
      t.string :description
      t.string :location
      t.datetime :date
      t.string :contact

      t.timestamps
    end
  end
end
