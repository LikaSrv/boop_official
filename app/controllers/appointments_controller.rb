class AppointmentsController < ApplicationController

  def new
    @date = params[:date]
    @time = params[:time]
    @appointment = Appointment.new
    @professional = Professional.find(params[:professional_id])
    @current_user_pets = current_user.pets
    @pets_name = @current_user_pets.map { |pet| pet.name }
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.start_time = Time.zone.parse("#{params[:appointment][:date]} #{params[:appointment][:start_time]}")
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

  private

  def appointment_params
    params.require(:appointment).permit(:date, :start_time, :professional_id, :user_id, :address, :reason, :pet_id)
  end
end
