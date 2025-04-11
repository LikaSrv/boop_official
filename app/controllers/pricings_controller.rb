class PricingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @pricings = Pricing.all.order(:created_at)
    @all_specialty = [
      {
        specialty: "Vétérinaire",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/judy-beth-morris-5Bi6MWlWMbw-unsplash.jpg"
      },
      {
        specialty: "Toiletteur",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/toiletteur.jpg"
      },
      {
        specialty: "Comportementaliste",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/comportementalist.jpg"
      },
      {
        specialty: "Pension",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/pension.jpg"
      },
      {
        specialty: "Promeneur",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/promeneur.jpg"
      },
      {
        specialty: "Nutritionniste",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/nutritionniste.jpg"
      },
      {
        specialty: "Petsitter",
        photo: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/general_images/petsitteur.jpg"
      }
    ]
  end

  def show
    @pricing = Pricing.find(params[:id])
  end


end
