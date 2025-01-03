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
  end

  private

  def pet_params
    params.require(:pet).permit(:name, :sex, :photo, :species, :user, :appointment, :races, :birthday, :weight, :identification, :spayed_neutered, :medical_background,
                        vaccinations_attributes: [:id, :name, :administration_date, :next_booster_date, :_destroy])
  end

  def vaccination_params
    params.require(:vaccination).permit(:name, :administation_date, :next_booster_date, :vet_name, :vet_phone, :pet_id)
  end
end
