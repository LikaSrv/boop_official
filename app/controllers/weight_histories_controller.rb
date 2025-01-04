class WeightHistoriesController < ApplicationController
  before_action :set_pet

  def new
    @weight_history = WeightHistories.new
    @pet = Pet.find(params[:pet_id])
  end

  def create
    @weight_history = WeightHistories.new(weight_history_params)
    if @weight_history.save!
      redirect_to pet_path(@pet), notice: "Le poids a bien été enregistré."
    else
      render :new, alert: "Le poids n'a pas été enregistré."
    end
  end

  # destroy à revoir
  def destroy
    @weight_history = @pet.weight_histories.find(params[:id])
    if @weight_history.destroy
      redirect_to pet_path(@pet), notice: "Le poids a bien été supprimée"
    else
      render new, alert: "Erreur lors de la suppression de le poids"
    end
  end

  private

  def set_pet
    @pet = Pet.find(params[:pet_id])
  end

  def weight_history_params
    params.require(:weight_history).permit(:weight, :date, :pet)
  end
end
