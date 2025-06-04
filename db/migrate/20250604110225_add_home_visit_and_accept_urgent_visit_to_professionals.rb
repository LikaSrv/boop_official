class AddHomeVisitAndAcceptUrgentVisitToProfessionals < ActiveRecord::Migration[7.1]
  def change
    add_column :professionals, :homeVisit, :boolean
    add_column :professionals, :acceptUrgentVisit, :boolean
  end
end
