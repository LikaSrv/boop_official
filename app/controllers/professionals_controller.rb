class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  helper_method :isOpened?, :isClosed?, :availabilitiesOfTheDay, :allTimeSlotsOfTheDay, :hasAvailableCapacity?, :last_valid_token_for_user
  before_action :validate_pro_signup_token, only: [:new, :create]


  def index
    # search
    if params[:query].present? && !params[:query_address].present?
      @professionals = Professional.search_by_specialty_and_name(params[:query])
    elsif params[:query_address].present? && !params[:query].present?
      @professionals = Professional.search_by_adresse(params[:query_address])
    elsif params[:query].present? && params[:query_address].present?
      @professionals = Professional.search_by_specialty_and_name(params[:query])
      .where("address ILIKE ?", "%#{params[:query_address]}%")
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
    @all_specialty = ["Vétérinaire", "Toiletteur", "Comportementaliste", "Pension", "Promeneur", "Nutritionniste", "Petsitter"]
  end

  def create
    @professional = Professional.new(professional_params)
    @professional.user = current_user
    @user = current_user
    @professional.rating = 0
    @professional.capacity = 1
    if @professional.save!
      photo_url = "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/uploaded_photos/#{@professional.photo.key}"
      @professional.update!(photo_url: photo_url)

      @order.increment!(:pro_accounts_created)
      # Invalide le token si quota atteint
      if @order.pro_accounts_created >= (@order.pricing.capacity || 1)
        @order.update!(pro_signup_token: nil)
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

    @appointment = Appointment.new

    @reviews = Review.where(professional: @professional)
    opening_hours = OpeningHour.where(professional: @professional)
    @open_days = opening_hours.where(closed: false).pluck(:day_of_week)
    @closed_days = opening_hours.where(closed: true).pluck(:day_of_week)
    @all_closed_days = get_all_closed_days(@professional)

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

      redirect_to professional_edit_availibilities_path(@professional), notice: 'Votre profil professionnel a bien été mis à jour'
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
    all_closed_days = get_all_closed_days(professional).map { |day| day[:date] }
    if all_closed_days.include?(date)
      return false
    else
      return true
    end
  end

  # if a professional is closed on a specific day time
  def isClosed? (professional, datetime)
    closing_hour = ClosingHour.where(professional: professional, start_time: datetime)
    if closing_hour.empty?
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

    appointments = Appointment.where(professional: professional, start_time: date.beginning_of_day..date.end_of_day)
    appointments.each do |appointment|
      if !opening_time_slots.include?(appointment.start_time)
        opening_time_slots << appointment.start_time
      end
    end
    return opening_time_slots
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

  # fonction to get all closed day (exceptionnal + national days offs) of each professional
  def get_all_closed_days(professional)
    @opening_hours = OpeningHour.where(professional: professional)
    @closed_days = @opening_hours.where(closed: true).pluck(:day_of_week)

    @exceptionnal_closed_days = ClosingHour.where(professional: professional, whole_day: true)
    .pluck(:start_time)
    .map { |date| { name: "Fermeture exceptionnelle", date: date.to_date } }

    @national_days_offs = NationalDaysOff.pluck(:name, :date).map { |name, date| { name: name, date: date } }

    @all_closed_days = (@exceptionnal_closed_days + @national_days_offs).uniq.sort_by { |day| day[:date] }

    return @all_closed_days
  end

  def update_slots
    @selected_date = params[:selected_date].present? ? params[:selected_date] : Date.today# Récupérer la nouvelle date
    @professional = Professional.find(params[:professional_id]) # Exemple de récupération de professionnel
    opening_hours = OpeningHour.where(professional: @professional)
    @open_days = opening_hours.where(closed: false).pluck(:day_of_week)
    # Logique pour récupérer les créneaux disponibles pour cette date

    render partial: "show_slots", locals: { professional: @professional, selected_date: @selected_date.to_date }
  end

  def update_edit_slots
    @selected_date = params[:selected_date].present? ? params[:selected_date] : Date.today# Récupérer la nouvelle date
    @professional = Professional.find(params[:professional_id]) # Exemple de récupération de professionnel
    @opening_hours = OpeningHour.where(professional: @professional)
    @open_days = @opening_hours.where(closed: false).pluck(:day_of_week)
    # Logique pour récupérer les créneaux disponibles pour cette date

    render partial: "edit_slots", locals: { professional: @professional, selected_date: @selected_date.to_date }
  end


  def edit_availibilities
    @professional = Professional.find(params[:id])
    @opening_hours = OpeningHour.where(professional: @professional)

    @open_days = @opening_hours.where(closed: false).pluck(:day_of_week)

    @closed_days = @opening_hours.where(closed: true).pluck(:day_of_week)
    @all_closed_days = get_all_closed_days(@professional)

    @selected_date = find_next_open_date(@closed_days)

    # Récupérer les jours de la semaine ouverts (0 = Dimanche, 1 = Lundi, ..., 6 = Samedi)
    open_days_of_week = @opening_hours.where(closed: false).pluck(:day_of_week)

    # Créer un hash pour stocker les dates ouvertes pour chaque mois
    @open_dates_per_month = {}

    # Boucle sur les 6 prochains mois pour trouver les dates ouvertes
    (0..5).each do |i|
      month_date = Date.today >> i # Déplace la date vers le mois correspondant
      first_day = month_date.beginning_of_month
      last_day = month_date.end_of_month

      # Filtrer les dates correspondant aux jours ouverts
      open_dates = (first_day..last_day).select { |date| open_days_of_week.include?(date.wday) }

      @open_dates_per_month[month_date.month] = open_dates
    end
  end

  # fonction to know if there are still available capacity to create a professional account
  def hasAvailableCapacity? (user)
    if user.professionals.count < numberOfProfessionals(user)
      return true
    else
      return false
    end
  end

  # fonction to validate the pro signup token
  def validate_pro_signup_token
    if params[:token].blank?
      redirect_to root_path, alert: "Lien manquant."
      return
    end

    @order = Order.find_by(pro_signup_token: params[:token], state: 'paid')

    if @order.pro_signup_token.nil?
      redirect_to root_path, alert: "Ce lien n’est plus valide."
    end

    unless @order
      redirect_to root_path, alert: "Lien invalide ou expiré."
      return
    end

    max_allowed = @order.pricing.capacity || 1
    already_created = @order.pro_accounts_created || 0

    if already_created >= max_allowed
      redirect_to root_path, alert: "Le nombre maximal de comptes pro a déjà été atteint pour cette commande."
    end

    @user = @order.user
  end

  def last_valid_token_for_user(user)
    orders = Order
      .includes(:pricing)
      .where(user: user, state: 'paid')
      .where.not(pro_signup_token: nil)

    orders.each do |order|
      max_allowed = order.pricing.capacity
      if order.pro_accounts_created.to_i < max_allowed
        return order.pro_signup_token
      end
    end

    nil
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

  def numberOfProfessionals(user)
    orders = user.orders.where(state: "paid")
    total_capacity = 0
    orders.each do |order|
      total_capacity += order.pricing.capacity
    end
    return total_capacity
  end
end
