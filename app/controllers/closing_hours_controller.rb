class ClosingHoursController < ApplicationController

  def new
    closing_hour = ClosingHour.new
  end

  def check
    professional = Professional.find(params[:professional_id])
    start_time = DateTime.parse(params[:start_time])
    end_time = DateTime.parse(params[:end_time])

    # Vérification si une closing_hour existe déjà pour cette période
    existing_closing_hour = ClosingHour.where(professional_id: professional.id, start_time: start_time).exists?

    if existing_closing_hour
      # Si l'horaire existe déjà, renvoyer l'ID de l'existant
      existing_record = ClosingHour.where(professional_id: professional.id, start_time: start_time).exists?
      render json: { exists: true, id: existing_record.id }
    else
      render json: { exists: false }
    end
  end


  def create
    closing_hour = ClosingHour.new(closing_hour_params)
    closing_hour.save!
  end

  def destroy
    closing_hour = ClosingHour.find(params[:id])
    closing_hour.destroy!
  end

  private

  def closing_hour_params
    params.require(:closing_hour).permit(:start_time, :end_time, :professional_id, :whole_day)
  end
end
