class AppointmentsController < ApplicationController

  def new
    @appointment = Appointment.new
    @professionals = Professional.all
    @professional = Professional.find(params[:professional_id])
    @users = User
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.professional = Professional.find(params[:professional_id])
    @appointment.user = current_user
    if @appointment.save
      redirect_to appointment_path(@appointment)
    else
      render :new
    end

  end

  def show
    @appointment = Appointment.find(params[:id])
    end

  private

  def appointment_params
    params.require(:appointment).permit(:date, :start_time, :end_time, :professional_id, :user_id)
  end
end
