class CreateShelters < ActiveRecord::Migration[7.1]
  def change
    create_table :shelters do |t|
      t.string :name
      t.string :phone
      t.string :address
      t.string :photo

      t.timestamps
    end
  end
end
