class AddIntervalToProfessional < ActiveRecord::Migration[7.1]
  def change
    add_column :professionals, :interval, :integer
  end
end
