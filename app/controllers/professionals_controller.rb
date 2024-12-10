class ProfessionalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :index, :show ]

  def home
    #cartes des catégories de professionnels
    #afficher les rdv à venir si user connecté
  end

  def index
    @professionals = Professional.all
  end

  def new
  end

  def create
  end

  def show
    @professional = Professional.find(params[:id])
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def search
  end

  private

  def appointment_params
    params.require(:professional).permit(:name, :address, :phone, :email, :specialty, :description, :rating)
  end
end
