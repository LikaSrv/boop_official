class AddReasonToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :reason, :string
  end
end
