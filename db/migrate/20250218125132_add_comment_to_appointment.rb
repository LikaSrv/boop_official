class AddCommentToAppointment < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :comment, :string
  end
end
