class PetsController < ApplicationController

  def index
    @pets = Pet.all
  end

  def new
    @pet = Pet.new
    @pet.vaccinations.build # Initialise un champ pour une première vaccination
  end

  def create
    @pet = Pet.new(pet_params)
    @pet.user = current_user
    if @pet.save!
      redirect_to pet_path(@pet), notice: "Votre animal a bien été créé"
    else
      render new, alert: "Erreur lors de la création de votre animal"
    end
  end

  def show
    @pet = Pet.find(params[:id])
    @vaccinations = @pet.vaccinations
    @weight_histories = @pet.weight_histories
    @weight_histories_data = []
    @weight_histories.each do |w|
      @weight_histories_data << w.weight
    end
    @weight_histories_labels = @weight_histories.map { |w| w.date.strftime("%Y-%m-%d") }
    @weight_histories_ids = @weight_histories.map { |w| w.id }
    @appointments = @pet.appointments
  end

  def edit
    @pet = Pet.find(params[:id])
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
    @pet = Pet.find(params[:id])
    # Mise à jour de l'animal et de ses attributs principaux
    if @pet.update(pet_params)
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
                        weight_histories_attributes: [:id, :weight, :date, :_destroy])
  end

  def vaccination_params
    params.require(:vaccination).permit(:name, :administation_date, :next_booster_date, :vet_name, :vet_phone, :pet_id)
  end
end
