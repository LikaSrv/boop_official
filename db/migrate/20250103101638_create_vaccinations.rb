class CreateVaccinations < ActiveRecord::Migration[7.1]
  def change
    create_table :vaccinations do |t|
      t.string :name
      t.date :administration_date
      t.date :next_booster_date
      t.string :vet_name
      t.integer :vet_phone
      t.references :pet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
