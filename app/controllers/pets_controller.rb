class PetsController < ApplicationController

  def index
    @pets = Pet.all
  end

  def new
    @pet = Pet.new
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
  end

  private

  def pet_params
    params.require(:pet).permit(:name, :age, :sex, :photo, :species, :user, :appointment)
  end
end
