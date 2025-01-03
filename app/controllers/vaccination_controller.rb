class VaccinationController < ApplicationController

  def new
    @vaccination = Vaccination.new
    @pet = Pet.find(params[:pet_id])
  end

  def create
    @vaccination = Vaccination.new(vaccination_params)
    if @vaccination.save!
      notice: "Votre vaccination a bien été créée"
    else
      render new, alert: "Erreur lors de la création de votre vaccination"
    end
  end

  def destroy
    @vaccination = Vaccination.find(params[:id])
    if @vaccination.destroy
      redirect_to pet_path(@vaccination.pet), notice: "Votre vaccination a bien été supprimée"
    else
      render new, alert: "Erreur lors de la suppression de votre vaccination"
    end
  end

  private

  def vaccination_params
    params.require(:vaccination).permit(:name, :administation_date, :next_booster_date, :vet_name, :vet_phone, :pet_id)
  end

end
