class CreateAnimals < ActiveRecord::Migration[7.1]
  def change
    create_table :animals do |t|
      t.string :name
      t.string :age
      t.string :description
      t.string :photo
      t.string :sex
      t.string :species
      t.string :shelter

      t.timestamps
    end
  end
end
