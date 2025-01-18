class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :about, :contact, :privacy_policy, :terms]

  def home
    if user_signed_in?
      @appointments = current_user.appointments
    end

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

    @available_specialty = []
    @professionals = Professional.all
    @professionals.each do |professional|
      @available_specialty << professional.specialty
    end

    @animals = Animal.all
    @pet_alerts = PetAlert.where(status: "false")
  end

  def about
    # Vous pouvez ajouter de la logique ici si nécessaire
  end


  def contact
    # Logique pour la page de contact
  end

  def privacy_policy
    # Logique pour la page de politique de confidentialité
  end

  def terms
    # Logique pour les conditions générales
  end
end
