class AppointmentsController < ApplicationController

  def new
    @date = params[:date]
    @time = params[:time]
    @appointment = Appointment.new
    @professional = Professional.find(params[:professional_id])
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.professional = Professional.find(params[:professional_id])
    @appointment.user = current_user
    if @appointment.save!
      redirect_to professional_appointment_path(@appointment.professional, @appointment)
    else
      render :new, alert: "Erreur lors de la création de votre rendez-vous"
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    @professional = @appointment.professional
  end

  def pro_index
    @professionals = Professional.where(user: current_user)
    @user = current_user
    @professional = Professional.find(params[:id])
    start_date = params.fetch(:start_date, Date.today).to_date
    @appointments = Appointment.where(professional: @professional, start_time: start_date.beginning_of_week..start_date.end_of_week)

  end

  def pro_show
    @professionals = Professional.where(user: current_user)
    @professional = Professional.find(params[:id])
    @appointments = Appointment.where(professional: @professional)
    @appointment = Appointment.find(params[:id])
  end


  private

  def appointment_params
    params.require(:appointment).permit(:date, :start_time, :professional_id, :user_id, :address)
  end
end
