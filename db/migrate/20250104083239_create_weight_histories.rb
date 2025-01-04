class CreateWeightHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :weight_histories do |t|
      t.float :weight
      t.date :date
      t.references :pet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
