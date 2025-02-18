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
    @closing_hour = ClosingHour.new(closing_hour_params)
    if @closing_hour.save!
      @opening_hours = OpeningHour.where(professional: @closing_hour.professional)
      @closed_days = @opening_hours.where(closed: true).pluck(:day_of_week)

      @exceptionnal_closed_days = ClosingHour.where(professional: @closing_hour.professional, whole_day: true)
      .select(:id, :start_time)
      .map { |closing_hour| { id: closing_hour.id, name: "Fermeture exceptionnelle", date: closing_hour.start_time.to_date } }

      @national_days_offs = NationalDaysOff.pluck(:name, :date).map { |name, date| { name: name, date: date } }

      @all_closed_days = (@exceptionnal_closed_days + @national_days_offs).uniq.sort_by { |day| day[:date] }

      respond_to do |format|
        format.json {
          render json: {
            success: true,
            message: "Avis ajouté avec succès",
            closing_hour: @closing_hour.as_json,
            html: render_to_string(partial: "professionals/all_closed_days_list", locals: { all_closed_days: @all_closed_days, exceptionnal_closed_days: @exceptionnal_closed_days })
          },
          status: :created
        }
      end
      else
        respond_to do |format|
          format.json { render json: { success: false }, status: :unprocessable_entity }
        end
    end
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
