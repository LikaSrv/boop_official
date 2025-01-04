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
