class WeightHistoriesController < ApplicationController
  before_action :set_pet

  def new
    @weight_history = WeightHistory.new
    @pet = Pet.find(params[:pet_id])
  end

  def create
    @weight_history = @pet.weight_histories.create(weight_history_params)

    if @weight_history.save!
      render json: { weight_history: @weight_history }, status: :created
    else
      render json: { errors: @weight_history.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @pet = Pet.find(params[:pet_id])
    @weight_history = WeightHistory.find(params[:id])
    if @weight_history.update(weight_history_params)
      render json: { weight_history: @weight_history }, status: :created
    else
      render json: { errors: @weight_history.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # destroy à revoir
  def destroy
    @pet = Pet.find(params[:pet_id])
    @weight_history = WeightHistory.find(params[:id])
    if @weight_history.destroy
      render json: { weight_history: @weight_history }, status: :created
    else
      render json: { errors: @weight_history.errors.full_messages }, status: :unprocessable_entity
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
