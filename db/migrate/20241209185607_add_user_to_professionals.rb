class AddUserToProfessionals < ActiveRecord::Migration[7.1]
  def change
    add_reference :professionals, :user, null: false, foreign_key: true
  end
end
