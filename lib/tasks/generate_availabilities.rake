namespace :availabilities do
  desc "Génère des créneaux pour les professionnels pour maintenir 30 jours de disponibilité"
  task generate: :environment do
    Professional.find_each do |professional|
      # Détermine la date la plus avancée actuellement disponible
      last_date = professional.availabilities.maximum(:date) || Date.current

      # Vérifie s'il manque des jours pour arriver à 30
      ((last_date + 1)..(Date.current + 30)).each do |new_date|
        generate_availabilities(professional.opening_hours, professional.interval, new_date)
      end
    end

    puts "Créneaux générés pour tous les professionnels jusqu'à 30 jours."
  end
end
