class AddAvailabilityToAppointment < ActiveRecord::Migration[7.1]
  def change
    add_reference :appointments, :availability, null: false, foreign_key: true
  end
end
