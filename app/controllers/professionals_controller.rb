class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :index, :show ]

  def home
    if user_signed_in?
      @appointments = current_user.appointments.upcoming
    end
  end

  def index
    # search
    @professionals = Professional.search_by_specialty_address_and_name(params[:query])

    if params[:query].present?
      @professionals = Professional.search_by_specialty_address_and_name(params[:query])
    elsif params[:specialty].present?
      @professionals = Professional.where(specialty: params[:specialty])
    else
      @professionals = Professional.all
    end

    @appointments = Appointment.where(professional: @professional)
    @reviews = []
    @appointments.each do |appointment|
      @reviews << Review.find_by(appointment: appointment.review)
    end

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
    @professional = Professional.new
  end

  def create
    @professional = Professional.new(appointment_params)
    @professional.user = current_user
    @user = current_user
    if @professional.save!
      redirect_to pro_index_user_path(@user), notice: 'Votre profil professionnel a bien été créé'
    else
      render :new, status: :unprocessable_entity, notice: 'Votre profil professionnel n\'a pas pu être créé car tous les champs n\'ont pas été remplis'
    end
  end

  def show
    @professional = Professional.find(params[:id])
    @professional.rating = 0
    @reviews = Review.where(professional: @professional)
    @appointment = Appointment.new

  end

  def pro_index
    @professionals = Professional.where(user: current_user)
  end

  def pro_show
    @professionals = Professional.where(user: current_user)
    start_date = params.fetch(:start_date, Date.today).to_date
    @appointments = Appointment.where(professional: @professionals[0], start_time: start_date.beginning_of_week..start_date.end_of_week)
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
    params.require(:professional).permit(:name, :address, :phone, :email, :specialty, :description, :rating, :latitude, :longitude, :photo)
  end
end
