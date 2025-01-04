class VaccinationsController < ApplicationController
  before_action :set_pet

  def new
    @vaccination = Vaccination.new
    @pet = Pet.find(params[:pet_id])
  end

  def create
    @vaccination = Vaccination.new(vaccination_params)
    @vaccination.pet_id = @pet.id
    if @vaccination.save!
      render json: { vaccination: @vaccination }, status: :created
    else
      render json: { errors: @vaccination.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # destroy à revoir
  def destroy
    @vaccination = @pet.vaccinations.find(params[:id])
    if @vaccination.destroy
      redirect_to pet_path(@pet), notice: "Votre vaccination a bien été supprimée"
    else
      render new, alert: "Erreur lors de la suppression de votre vaccination"
    end
  end

  private

  def set_pet
    @pet = Pet.find(params[:pet_id])
  end

  def vaccination_params
    params.require(:vaccination).permit(:name, :administration_date, :next_booster_date, :vet_name, :vet_phone, :pet_id)
  end

end
