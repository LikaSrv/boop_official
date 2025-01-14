class PetAlertsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  def index
    @pet_alerts = PetAlert.all.order(date: :desc)
  end

  def new
    @pet_alert = PetAlert.new
  end

  def create
    @pet_alert = PetAlert.new(pet_alert_params)
    @pet_alert.status = false
    @pet_alert.user = current_user if current_user.present?

    if @pet_alert.save
      redirect_to pet_alert_path(@pet_alert), notice: "Alerte créée avec succès"
    else
      flash.now[:alert] = @pet_alert.errors.full_messages.join(", ")
      render :new
    end
  end

  def show
    @pet_alert = PetAlert.find(params[:id])
  end

  def edit
    @pet_alert = PetAlert.find(params[:id])
  end

  def update
    @pet_alert = PetAlert.find(params[:id])
    @pet_alert.update(pet_alert_params)
  end

  def destroy
    @pet_alert = PetAlert.find(params[:id])
    if @pet_alert.destroy
      redirect_to root_path, notice: "Alerte supprimée avec succès"
    else
      render :show, alert: "Erreur lors de la suppression de l'alerte"
    end
  end

  private

  def pet_alert_params
    params.require(:pet_alert).permit(:title, :description, :date, :location, :photo, :user_id, :contact, :status)
  end

end
