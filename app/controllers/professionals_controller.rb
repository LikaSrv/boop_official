class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    # search
    # @professionals = Professional.search_by_specialty_address_and_name(params[:query])

    if params[:query].present?
      @professionals = Professional.search_by_specialty_address_and_name(params[:query])
    elsif params[:specialty].present?
      @professionals = Professional.where(specialty: params[:specialty])
    else
      @professionals = Professional.all
    end

    @reviews = Review.where(professional: @professionals)
    @availabilities = Availability.where(professional: @professionals, status: true).select { |availability| availability.start_time > DateTime.now }

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

  def pro_index
    @professionals = Professional.where(user: current_user)
    @appointments = Appointment.where(professional: @professionals)
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
      photo_url = "#{ENV['SUPABASE_URL']}/storage/v1/object/public/uploaded_photos/#{@professional.photo.key}"
      @professional.update!(photo_url: photo_url)
      (0..31).each do |i|
        generate_availabilities(@professional.opening_hours, @professional.interval, Date.current + i)
      end
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

    @availabilities = Availability.where(professional: @professional, status: true).select { |availability| availability.start_time > DateTime.now }
    @available_months = @availabilities.pluck(:start_time).map { |date| date.month }.uniq

    @reviews = Review.where(professional: @professional)
    @appointment = Appointment.new
    if @reviews.empty?
      @average_rating = 0
    else
      @average_rating = @reviews.average(:rating).round.to_i
    end
    @professional.update(rating: @average_rating)
    @opening_hours = OpeningHour.where(professional: @professional)
    @marker = [{
      lat: @professional.latitude,
      lng: @professional.longitude
    }]
  end

  def pro_show
    @professionals = Professional.where(user: current_user)
    @professional = Professional.find(params[:professional_id])

    start_date = params.fetch(:start_date, Date.today).to_date
    @appointments = Appointment.where(professional: @professional, start_time: (start_date.beginning_of_week.beginning_of_day..start_date.end_of_week.end_of_day))

    opening_hours = OpeningHour.where(professional: @professional)
    @open_days = opening_hours.where(closed: false).pluck(:day_of_week)

    @availabilities = Availability.where(professional: @professional)

  end

  def edit
    @professional = Professional.find(params[:id])
  end

  def update
    @professional = Professional.find(params[:id])

    if @professional.update!(professional_params)
      # Mettre à jour photo_url
      if @professional.photo.attached?
        photo_url = "#{ENV['SUPABASE_URL']}/storage/v1/object/public/uploaded_photos/#{@professional.photo.key}"
        @professional.update!(photo_url: photo_url)
      end

      # Mettre à jour les coordonnées si l'adresse a changé
      if @professional.saved_change_to_address?
        @marker = [{
          lat: @professional.latitude,
          lng: @professional.longitude
        }]
      end

      # Mettre à jour les créneaux de disponibilités
      @professional.opening_hours.each do |opening_hour|
        if opening_hour.previous_changes.present?

          day_of_week = opening_hour.day_of_week

          # search all availabilities for that day of the week without any appointments
          availabilities = Availability.select do |availability|
            availability.professional == @professional &&
            availability.start_time.to_date.wday == day_of_week &&
            availability.appointments.count == 0
          end

          # destroy all availabilities for the day
          availabilities.each {|availability| availability.destroy}

          if opening_hour.closed === false
            # create new availabilities
            today = Date.current
            date =  today + (day_of_week - today.wday) % 7

            while date <= today + 31
              generate_availabilities_for_one_opening_hour(opening_hour, @professional.interval,  date )
              date += 7
            end

            # looking for duplicate availabilities and delete the ones without appointments
            duplicate_availabilities = Availability.where(professional: @professional)
                                          .group_by(&:start_time)
                                          .select { |_, availabilities| availabilities.size > 1 }
            duplicate_availabilities.each do |_, availabilities|
              availabilities.each do |availability|
                availability.destroy if availability.appointments.count == 0
              end
          end
        end
      end


       # Mettre à jour le statut des disponibilités
      availabilities = Availability.where(professional: @professional)
      availabilities.each do |availability|
        if availability.appointments.count < @professional.capacity
          availability.update(status: true)
        else
          availability.update(status: false)
        end
      end
    end

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

  # generate all availabilities for a professional
  def generate_availabilities(opening_hours, interval, date)

    closed_days = opening_hours.where(closed: true).pluck(:day_of_week)
    if !closed_days.include?(date.wday)
      opening_hour = opening_hours.find_by(day_of_week: date.wday)

      start_time_morning = DateTime.parse("#{date} #{opening_hour.open_time_morning}")
      end_time_morning = DateTime.parse("#{date} #{opening_hour.close_time_morning}")

      while start_time_morning + interval.minutes <= end_time_morning
        availability = Availability.new(
          professional: @professional,
          start_time: start_time_morning,
          status: 1
        )
        availability.save!

        # Incrémenter start_time de l'intervalle
        start_time_morning += interval.minutes
      end

      start_time_afternoon = DateTime.parse("#{date} #{opening_hour.open_time_afternoon}")
      end_time_afternoon = DateTime.parse("#{date} #{opening_hour.close_time_afternoon}")

      while start_time_afternoon + interval.minutes <= end_time_afternoon
        availability = Availability.new(
          professional: @professional,
          start_time: start_time_afternoon,
          status: 1
        )
        availability.save!

        # Incrémenter start_time de l'intervalle
        start_time_afternoon += interval.minutes
      end

    end
  end

  # generate availabilities after editing opening hours
  def generate_availabilities_for_one_opening_hour(opening_hour, interval, date)

    start_time_morning = DateTime.parse("#{date} #{opening_hour.open_time_morning}")
    end_time_morning = DateTime.parse("#{date} #{opening_hour.close_time_morning}")

    while start_time_morning + interval.minutes <= end_time_morning
      availability = Availability.new(
        professional: @professional,
        start_time: start_time_morning,
        status: 1
      )
      availability.save!

      # Incrémenter start_time de l'intervalle
      start_time_morning += interval.minutes
    end

    start_time_afternoon = DateTime.parse("#{date} #{opening_hour.open_time_afternoon}")
    end_time_afternoon = DateTime.parse("#{date} #{opening_hour.close_time_afternoon}")

    while start_time_afternoon + interval.minutes <= end_time_afternoon
      availability = Availability.new(
        professional: @professional,
        start_time: start_time_afternoon,
        status: 1
      )
      availability.save!

      # Incrémenter start_time de l'intervalle
      start_time_afternoon += interval.minutes
    end

  end

  def edit_availibilities
    @professional = Professional.find(params[:id])
    @futur_availibilities = Availability.where("start_time >= ? AND professional_id = ? ", Time.now, @professional.id)
    @available_months = @futur_availibilities.pluck(:start_time).map { |date| date.month }.uniq
    @opening_hours = OpeningHour.where(professional: @professional)

  end

  def update_availibilities
    availability = Availability.find(params[:availability_id])
    availability.update!(status: !availability.status)
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
                                          :interval,
                                          :opening_hours_attributes => [:id, :day_of_week, :open_time_morning, :close_time_morning, :open_time_afternoon, :close_time_afternoon, :closed, :_destroy])
  end

    # Méthode pour vérifier si une disponibilité est dans les horaires d'ouverture
    def within_opening_hour?(opening_hour)
      opening_hour.any? do |hour|
        # Vérifie si l'heure de début de la disponibilité se trouve dans les heures d'ouverture du professionnel
        (start_time >= hour.open_time_morning && start_time <= hour.close_time_morning) ||
        (start_time >= hour.open_time_afternoon && start_time <= hour.close_time_afternoon)
      end
    end

end
