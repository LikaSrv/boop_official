class AddMedicalBgToPets < ActiveRecord::Migration[7.1]
  def change
    add_column :pets, :medical_background, :string
  end
end
