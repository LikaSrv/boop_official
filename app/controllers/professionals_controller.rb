class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

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

    @reviews = Review.where(professional: @professionals)

    # @reviews = []
    # @appointments.each do |appointment|
    #   @reviews << Review.find_by(appointment: appointment.review)
    # end

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
    @professional.capacity = 1
    (0..6).each do |day|
      @professional.opening_hours.build(day_of_week: day)
    end
  end

  def create
    @professional = Professional.new(professional_params)
    @professional.user = current_user
    @user = current_user
    @professional.rating = 0
    @professional.capacity = 1
    if @professional.save!
      redirect_to pro_index_user_path(@user), notice: 'Votre profil professionnel a bien été créé'
    else
      render :new, status: :unprocessable_entity, notice: 'Votre profil professionnel n\'a pas pu être créé car tous les champs n\'ont pas été remplis'
    end
  end


  def duplicate
    professional = Professional.find(params[:professional_id])
    duplicated_professional = professional.dup
    duplicated_professional.user = current_user
    duplicated_professional.photo.attach(professional.photo.blob)

    Rails.logger.debug "Duplicating professional: #{duplicated_professional.attributes}"

    if duplicated_professional.save!
      render json: { success: true }, status: :ok
    else
      Rails.logger.error "Duplication failed: #{duplicated_professional.errors.full_messages}"
      render json: { success: false, errors: duplicated_professional.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def show
    @professional = Professional.find(params[:id])
    @reviews = Review.where(professional: @professional)
    @appointment = Appointment.new
    if @reviews.empty?
      @average_rating = 0
    else
      @average_rating = @reviews.average(:rating).round.to_i
    end
    @professional.update(rating: @average_rating)
  end

  def pro_index
    @professionals = Professional.where(user: current_user)
    @appointments = Appointment.where(professional: @professionals)
  end

  def pro_show
    @professionals = Professional.where(user: current_user)
    @professional = Professional.find(params[:professional_id])

    start_date = params.fetch(:start_date, Date.today).to_date
    @appointments = Appointment.where(professional: @professional, date: (start_date.beginning_of_week.beginning_of_day..start_date.end_of_week.end_of_day))
  end

  def edit
    @professional = Professional.find(params[:id])
  end

  def update
    @professional = Professional.find(params[:id])

    if @professional.update!(professional_params)
      redirect_to edit_professional_path(@professional), notice: 'Votre profil professionnel a bien été mis à jour'
    else
      render :edit, status: :unprocessable_entity, notice: 'Votre profil professionnel n\'a pas pu être mis à jour car tous les champs n\'ont pas été remplis'
    end
  end

  def destroy
    @professional = Professional.find(params[:id])
    @professional.destroy
    redirect_to pro_index_user_path(current_user), notice: 'Votre profil professionnel a bien été supprimé'
  end

  def search
  end

  def edit_slots
    @professional = Professional.find(params[:id])
  end

  def update_slots

  end

  private

  def professional_params
    params.require(:professional).permit( :name,
                                          :address,
                                          :phone,
                                          :email,
                                          :specialty,
                                          :description,
                                          :rating,
                                          :latitude,
                                          :longitude,
                                          :photo,
                                          :capacity,
                                          :start_hour,
                                          :end_hour,
                                          :interval)
  end
end
