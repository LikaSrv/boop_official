class AddOpenTimeAndCloseTimeEveningToOpeningHours < ActiveRecord::Migration[7.1]
  def change
    add_column :opening_hours, :open_time_afternoon, :time
    add_column :opening_hours, :close_time_afternoon, :time
  end
end
