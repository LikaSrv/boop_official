class AddOpeningAndClosingTimeToProfessional < ActiveRecord::Migration[7.1]
  def change
    add_column :professionals, :start_hour, :integer
    add_column :professionals, :end_hour, :integer
    add_column :professionals, :interval, :integer
  end
end
