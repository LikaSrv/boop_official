class RemoveEndtimeFromAppointments < ActiveRecord::Migration[7.1]
  def change
    remove_column :appointments, :end_time, :string
  end
end
