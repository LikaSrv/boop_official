require 'net/http'
require 'uri'
require 'json'

class PetAlertsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  def index
    @pet_alerts = PetAlert.all.order(date: :desc)

    @markers = @pet_alerts.geocoded.map do |pet_alert|
      {
        lat: pet_alert.latitude,
        lng: pet_alert.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {pet_alert: pet_alert})
      }
    end

  end

  def new
    @pet_alert = PetAlert.new
  end

  def create
    @pet_alert = PetAlert.new(pet_alert_params)
    @pet_alert.status = false
    @pet_alert.user = current_user if current_user.present?

    # Attache la photo si elle est présente dans les paramètres
    if params[:pet_alert][:photo].present?
      @pet_alert.photo.attach(params[:pet_alert][:photo])
    end

    if @pet_alert.save
      photo_url = "#{ENV['SUPABASE_URL']}/storage/v1/object/public/uploaded_photos/#{@pet_alert.photo.key}"
      @pet_alert.update!(photo_url: photo_url)
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
    params.require(:pet_alert).permit(:title, :description, :date, :location, :photo, :user_id, :contact, :status, :latitude, :longitude)
  end

end
