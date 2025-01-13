class AppointmentsController < ApplicationController

  def new
    @date = params[:date]
    @time = params[:time]
    @appointment = Appointment.new
    @professional = Professional.find(params[:professional_id])
    @current_user_pets = current_user.pets
    # @pets_name = @current_user_pets.map { |pet| pet.name }
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.professional = Professional.find(params[:professional_id])
    @appointment.user = current_user
    start_time = Time.zone.parse("#{params[:appointment][:date]} #{params[:appointment][:start_time]}")
    @appointment.start_time = start_time
    available_slot = Availability.find_by(professional_id: params[:professional_id], start_time: start_time)
    @appointment.availability = available_slot
    if @appointment.save!
      if available_slot.appointments.count === Professional.find(params[:professional_id]).capacity
        available_slot.status = false
        available_slot.save!
      end
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
    params.require(:appointment).permit(:start_time, :professional_id, :user_id, :address, :reason, :pet_id, :availability_id)
  end
end
