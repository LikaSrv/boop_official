class AddWholeDayToClosingHour < ActiveRecord::Migration[7.1]
  def change
    add_column :closing_hours, :whole_day, :boolean, default: false
  end
end
