class ChangeUserIdNullConstraintInPetAlerts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :pet_alerts, :user_id, true
  end
end
