class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :index, :show ]

  def home
    #cartes des catégories de professionnels
    #afficher les rdv à venir si user connecté
  end

  def index
    @professionals = Professional.all

    @appointments = Appointment.where(professional: @professional)
    @reviews = []
    @appointments.each do |appointment|
      @reviews << Review.find_by(appointment: appointment.review)
    end
    @appointment = Appointment.new

  # The `geocoded` scope filters only flats with coordinates
    @markers = @professionals.geocoded.map do |professional|
      {
        lat: professional.latitude,
        lng: professional.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {professional: professional})
      }
    end

  end

  def new
  end

  def create
  end

  def show
    @professional = Professional.find(params[:id])
    @appointments = Appointment.where(professional: @professional)
    @reviews = []
    @appointments.each do |appointment|
      @reviews << Review.find_by(appointment: appointment.review)
    end
    @appointment = Appointment.new
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
    params.require(:professional).permit(:name, :address, :phone, :email, :specialty, :description, :rating, :latitude, :longitude)
  end
end
