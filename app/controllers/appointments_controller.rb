class AppointmentsController < ApplicationController

  def new
    @appointment = Appointment.new
    @professionals = Professional.all
    @users = User
  end

  def create
  end

  def show
    @appointment = Appointment.find(params[:id])
    end

  private

  def appointment_params
    params.require(:appointment).permit(:date, :start_time, :end_time, :professional_id, :user_id)
  end
end
