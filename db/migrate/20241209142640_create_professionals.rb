class CreateProfessionals < ActiveRecord::Migration[7.1]
  def change
    create_table :professionals do |t|
      t.string :name
      t.string :address
      t.integer :phone
      t.string :email
      t.string :specialty
      t.string :description
      t.integer :rating

      t.timestamps
    end
  end
end
