class VaccinationsController < ApplicationController

  def new
    @vaccination = Vaccination.new
    @pet = Pet.find(params[:pet_id])
  end

  def create
    @pet = Pet.find(params[:pet_id])
    @vaccination = Vaccination.new(vaccination_params)
    @vaccination.pet_id = @pet.id
    if @vaccination.save!
      render json: { vaccination: @vaccination }, status: :created
    else
      render json: { errors: @vaccination.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @pet = Pet.find(params[:pet_id])
    @vaccination = Vaccination.find(params[:id])
    if @vaccination.update(vaccination_params)
      render json: { vaccination: @vaccination }, status: :created
    else
      render json: { errors: @vaccination.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # destroy à revoir
  def destroy
    @pet = Pet.find(params[:pet_id])
    @vaccination = Vaccination.find(params[:id])
    if @vaccination.destroy
      render json: { vaccination: @vaccination }, status: :created
    else
      render json: { errors: @vaccination.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def vaccination_params
    params.require(:vaccination).permit(:name, :administration_date, :next_booster_date, :vet_name, :vet_phone, :pet_id)
  end

end
