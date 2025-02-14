class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  helper_method :isOpened?, :availabilitiesOfTheDay, :allTimeSlotsOfTheDay

  def index
    # search
    if params[:query].present?
      @professionals = Professional.search_by_specialty_address_and_name(params[:query])
    elsif params[:specialty].present?
      @professionals = Professional.where(specialty: params[:specialty])
    else
      @professionals = Professional.all
    end

    @reviews = Review.where(professional: @professionals)

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

    @appointment = Appointment.new

    @reviews = Review.where(professional: @professional)
    opening_hours = OpeningHour.where(professional: @professional)
    @open_days = opening_hours.where(closed: false).pluck(:day_of_week)
    @closed_days = opening_hours.where(closed: true).pluck(:day_of_week)

    @selected_date = find_next_open_date(@closed_days)

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

    # @availabilities = Availability.where(professional: @professional)

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

  # if a professional is closed on a specific day
  def isOpened? (professional, date)
    opening_hour = OpeningHour.where(professional: professional, day_of_week: date.wday, closed: false)
    if opening_hour.empty?
      return false
    else
      return true
    end
  end

  # if a professional is available at a specific time
  def isAvailable? (professional, date, start_time)
    appointment = Appointment.where(professional: professional, start_time: start_time)
    if appointment.empty?
      return true
    else
      return false
    end
  end

  # return all availabilities of a professional for a specific day
  def availabilitiesOfTheDay (professional, date)
    opening_time_slots = []
    if isOpened?(professional, date)
      opening_hour = OpeningHour.find_by(professional: professional, day_of_week: date.wday)

      start_time_morning = DateTime.parse("#{date} #{opening_hour.open_time_morning}")
      end_time_morning = DateTime.parse("#{date} #{opening_hour.close_time_morning}")

      while start_time_morning + professional.interval.minutes <= end_time_morning
        if isAvailable?(professional, date, start_time_morning)
          opening_time_slots << start_time_morning
          # Incrémenter start_time de l'intervalle
        end
        start_time_morning += professional.interval.minutes
      end

      start_time_afternoon = DateTime.parse("#{date} #{opening_hour.open_time_afternoon}")
      end_time_afternoon = DateTime.parse("#{date} #{opening_hour.close_time_afternoon}")

      while start_time_afternoon + professional.interval.minutes <= end_time_afternoon
        if isAvailable?(professional, date, start_time_afternoon)
        opening_time_slots << start_time_afternoon
        end
        # Incrémenter start_time de l'intervalle
        start_time_afternoon += professional.interval.minutes
      end
    end
    return opening_time_slots
  end

  # return all timeslots of a professional for a specific day
  def allTimeSlotsOfTheDay (professional, date)
    opening_time_slots = []
    if isOpened?(professional, date)
      opening_hour = OpeningHour.find_by(professional: professional, day_of_week: date.wday)

      start_time_morning = DateTime.parse("#{date} #{opening_hour.open_time_morning}")
      end_time_morning = DateTime.parse("#{date} #{opening_hour.close_time_morning}")

      while start_time_morning + professional.interval.minutes <= end_time_morning

          opening_time_slots << start_time_morning
          # Incrémenter start_time de l'intervalle

        start_time_morning += professional.interval.minutes
      end

      start_time_afternoon = DateTime.parse("#{date} #{opening_hour.open_time_afternoon}")
      end_time_afternoon = DateTime.parse("#{date} #{opening_hour.close_time_afternoon}")

      while start_time_afternoon + professional.interval.minutes <= end_time_afternoon

        opening_time_slots << start_time_afternoon

        # Incrémenter start_time de l'intervalle
        start_time_afternoon += professional.interval.minutes
      end
    end
    return opening_time_slots
  end

  def edit_availibilities
    @professional = Professional.find(params[:id])
    @futur_availibilities = Availability.where("start_time >= ? AND professional_id = ? ", Time.now, @professional.id)
    @available_months = @futur_availibilities.pluck(:start_time).map { |date| date.month }.uniq
    @opening_hours = OpeningHour.where(professional: @professional)

  end

  def update_slots
    @selected_date = params[:selected_date].present? ? params[:selected_date] : Date.today# Récupérer la nouvelle date
    @professional = Professional.find(params[:professional_id]) # Exemple de récupération de professionnel
    opening_hours = OpeningHour.where(professional: @professional)
    @open_days = opening_hours.where(closed: false).pluck(:day_of_week)
    # Logique pour récupérer les créneaux disponibles pour cette date

    render partial: "show_slots", locals: { professional: @professional, selected_date: @selected_date.to_date }
  end

  # Fonction pour trouver la prochaine date ouverte
def find_next_open_date(closed_days)
  current_date = Date.today  # Date actuelle
  # Tant que le jour de la semaine actuel est fermé, on passe au jour suivant
  while closed_days.include?(current_date.wday)  # wday donne le jour de la semaine (0=dimanche, 1=lundi, ...)
    current_date += 1 # On avance d'un jour
  end
  current_date
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
