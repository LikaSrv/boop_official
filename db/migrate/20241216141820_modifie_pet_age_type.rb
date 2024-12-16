class ModifiePetAgeType < ActiveRecord::Migration[7.1]

    def change
      change_column :pets, :age, :string
    end

end
