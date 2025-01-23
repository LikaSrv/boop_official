namespace :availabilities do
  desc "Génère des créneaux pour les professionnels pour maintenir 30 jours de disponibilité"
  task generate: :environment do
    Professional.find_each do |professional|
      # Détermine la date la plus avancée actuellement disponible
      last_date = professional.availabilities.maximum(:start_time).to_date || Date.current
      puts last_date

      professional.generate_availabilities(professional.opening_hours, professional.interval, last_date+1)
    end

    puts "Créneaux générés pour tous les professionnels"
  end
end
