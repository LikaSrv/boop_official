class AddRacesLabelToAnimals < ActiveRecord::Migration[7.1]
  def change
    add_column :animals, :races_label, :string
  end
end
