class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :index, :show ]

  def home
    if user_signed_in?
      @appointments = current_user.appointments.upcoming
    end
  end

  def index
    @professionals = Professional.all
  end

  def new
    @professional = Professional.new
  end

  def create
  end

  def show
    @professional = Professional.find(params[:id])
  end

  def edit

  end

  def update
  end

  def destroy
  end

  def search
  end

  private

  def appointment_params
    params.require(:professional).permit(:name, :address, :phone, :email, :specialty, :description, :rating)
  end
end
