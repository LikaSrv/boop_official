class SheltersController < ApplicationController

  def index
    @shelters = Shelter.all
  end

  def show
    @shelter = Shelter.find(params[:id])
  end

  def new
    @shelter = Shelter.new
  end

  def create
    @shelter = Shelter.new(shelter_params)
    if @shelter.save
      redirect_to @shelter, notice: 'Shelter was successfully created.'
    else
      render :new
    end
  end

  def edit
    @shelter = Shelter.find(params[:id])
  end

  def update
    @shelter = Shelter.find(params[:id])
    if @shelter.update(shelter_params)
      redirect_to @shelter, notice: 'Shelter was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @shelter = Shelter.find(params[:id])
    @shelter.destroy
    redirect_to shelters_path, notice: 'Shelter was successfully destroyed.'
  end

  private

  def shelter_params
    params.require(:shelter).permit(:name, :address, :phone, :email)
  end
end
