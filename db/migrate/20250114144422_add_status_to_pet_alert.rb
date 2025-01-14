class AddStatusToPetAlert < ActiveRecord::Migration[7.1]
  def change
    add_column :pet_alerts, :status, :boolean
  end
end
