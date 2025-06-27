class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :about, :contact, :privacy_policy, :terms]

  def home
    if user_signed_in?
      @appointments = current_user.appointments
    end

    @all_specialty = [
      {
        specialty: "Vétérinaire",
        photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//veto-400x.webp"
      },
      {
        specialty: "Comportementaliste",
        photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//comportementalist-400x.webp"
      },
      {
        specialty: "Nutritionniste",
        photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//nutritionniste-400x.webp"
      },
      {
        specialty: "Toiletteur",
        photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//toiletteur-400x.webp"
      },
      {
        specialty: "Pension",
        photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//pension-400x.webp"
      },
      {
        specialty: "Promeneur",
        photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//promeneur-400x.webp"
      },
      {
        specialty: "Petsitter",
        photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//petsitter-400x.webp"
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
