class AppointmentsController < ApplicationController

  def new
  end

  def create
  end

  def show
  end

  private

  def appointment_params
    params.require(:appointment).permit(:date, :start_time, :end_time, :professional_id, :user_id)
  end
end
