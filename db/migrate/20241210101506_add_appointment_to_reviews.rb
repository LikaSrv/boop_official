class AddAppointmentToReviews < ActiveRecord::Migration[7.1]
  def change
    add_reference :reviews, :appointment, null: false, foreign_key: true
  end
end
