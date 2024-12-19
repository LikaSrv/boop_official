class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :about, :contact, :privacy_policy, :terms]

  def home
    if user_signed_in?
      @appointments = current_user.appointments.upcoming_and_today
    end

    @all_specialty = [
      {
        specialty: "Vétérinaire",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/judy-beth-morris-5Bi6MWlWMbw-unsplash_funbpk.jpg"
      },
      {
        specialty: "Toiletteur",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/reba-spike-PEQIIwnIGdo-unsplash_yfvjlt.jpg"
      },
      {
        specialty: "Comportementaliste",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359896/comportementalist_wthrkt.jpg"
      },
      {
        specialty: "Pension",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359894/pension_ujblqm.jpg"
      },
      {
        specialty: "Promeneur",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1733824978/development/m4vlzbcsqfd656mz4bfevhz4gybu.jpg"
      },
      {
        specialty: "Nutritionniste",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359894/nutritionniste_jyqrm8.jpg"
      },
      {
        specialty: "Petsitter",
        photo: "https://res.cloudinary.com/dsbteudoz/image/upload/v1734359894/petsitter_fskzo9.jpg"
      }
    ]

    @available_specialty = []
    @professionals = Professional.all
    @professionals.each do |professional|
      @available_specialty << professional.specialty
    end
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
