class PetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet, only: [:show, :edit, :update]
  before_action :authorize_professional_access, only: [:show_for_pro]


  def index
    @pets = Pet.all
  end

  def new
    @pet = Pet.new
    @pet.vaccinations.build # Initialise un champ pour une première vaccination
    @pet.weight_histories.build if params[:weight] # Crée un WeightHistory uniquement si un poids est fourni
  end

  def create
    @pet = Pet.new(pet_params)
    @pet.user = current_user

    # Supprimer les WeightHistories vides
    @pet.weight_histories.reject { |wh| wh.weight.blank? }

    if @pet.save!
      photo_url = "#{ENV['SUPABASE_URL']}/storage/v1/object/public/uploaded_photos/#{@pet.photo.key}"
      @pet.update!(photo_url: photo_url)
      respond_to do |format|
        format.json { render json: { success: true, message: "Votre animal a été ajouté avec succès"
        }, status: :created }
        format.html { redirect_to user_pet_path(current_user, @pet), notice: "Avis ajouté avec succès." }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @pet.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end

  end

  def show
    @vaccinations = @pet.vaccinations.sort_by { |v| [v.name.downcase, v.next_booster_date] }
    @weight_histories = @pet.weight_histories
    @weight_histories_data = []
    @weight_histories.each do |w|
      @weight_histories_data << w.weight
    end
    @weight_histories_labels = @weight_histories.map { |w| w.date.strftime("%Y-%m-%d") }
    @weight_histories_ids = @weight_histories.map { |w| w.id }
    @appointments = @pet.appointments.sort { |a, b| b.start_time <=> a.start_time }
    # raise
  end

  def show_for_pro
    @vaccinations = @pet.vaccinations.sort_by { |v| [v.name.downcase, v.next_booster_date] }
    @weight_histories = @pet.weight_histories
    @weight_histories_data = []
    @weight_histories.each do |w|
      @weight_histories_data << w.weight
    end
    @weight_histories_labels = @weight_histories.map { |w| w.date.strftime("%Y-%m-%d") }
    @weight_histories_ids = @weight_histories.map { |w| w.id }
    @appointments = @pet.appointments.sort { |a, b| b.start_time <=> a.start_time }
  end

  def edit
    @vaccinations = @pet.vaccinations
    @weight_histories = @pet.weight_histories
    @weight_histories_data = []
    @weight_histories.each do |w|
      @weight_histories_data << w.weight
    end
    @weight_histories_labels = @weight_histories.map { |w| w.date.strftime("%Y-%m-%d") }
    @weight_histories_ids = @weight_histories.map { |w| w.id }
  end

  def update
    # Mise à jour de l'animal et de ses attributs principaux
    if @pet.update(pet_params)
      if @pet.photo.attached?
        photo_url = "#{ENV['SUPABASE_URL']}/storage/v1/object/public/uploaded_photos/#{@pet.photo.key}"
        @pet.update_column(:photo_url, photo_url)
      end
      # Si la mise à jour réussit, on redirige avec un message de succès
      flash[:notice] = "L'animal a bien été mis à jour."
      redirect_to user_pet_path(current_user, @pet)
    else
      # Si la mise à jour échoue, on rend la vue d'édition avec les erreurs
      flash[:alert] = "Impossible de mettre à jour l'animal."
      render :edit
    end
  end

  def destroy
    @pet = Pet.find_by(id: params[:id], user: current_user) # Sécurise avec current_user
    if @pet.destroy
      render json: { message: "L'animal a été supprimé." }, status: :no_content
    else
      render json: { errors: @pet.errors.full_messages }, status: :unprocessable_entity
    end
    # if @pet.destroy!
    #   redirect_to root_path, notice: "L'animal a bien été supprimé"
    # else
    #   redirect_to root_path, alert: "Animal introuvable"
    # end
  end

  private

  def pet_params
    params.require(:pet).permit(:name, :sex, :photo, :species, :user, :appointment, :races, :birthday, :weight, :identification, :spayed_neutered, :medical_background,
                        vaccinations_attributes: [:id, :name, :administration_date, :next_booster_date, :_destroy],
                        weight_histories_attributes: [:id, :weight, :date, :_destroy]).tap do |whitelisted|
                          # Remplacer les valeurs vides ou contenant uniquement des espaces par "Non renseigné"
                          whitelisted.each do |key, value|
                            if value.is_a?(String) && value.strip.blank?
                              whitelisted[key] = "Non renseigné"
                            end
                          end
                        end
  end

  def set_pet
    @pet = current_user.pets.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Accès non autorisé ou animal introuvable."
  end

  def authorize_professional_access
    @pet = Pet.find(params[:id])
    @professional = Professional.find_by(id: params[:professional_id])

    # Vérifie que le pro a un rendez-vous à venir ou passé avec ce pet
    has_appointment = Appointment.exists?(pet: @pet, professional: @professional)

    unless has_appointment
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end


end
