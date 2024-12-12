class RemoveAppointmentReferences < ActiveRecord::Migration[7.1]
  def change
    remove_reference :reviews, :appointment, null: false, foreign_key: true
  end
end
