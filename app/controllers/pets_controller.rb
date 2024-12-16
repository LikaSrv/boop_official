class PetsController < ApplicationController

  def index
    @pets = Pet.all
  end

  def show
    @pet = Pet.find(params[:id])
    @appointments = Appointment.where(pet_id: @pet.id)
  
  end
end
