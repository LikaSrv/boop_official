class CreatePets < ActiveRecord::Migration[7.1]
  def change
    create_table :pets do |t|
      t.string :name
      t.integer :age
      t.string :description
      t.string :photo
      t.string :sex
      t.string :species

      t.timestamps
    end
  end
end
