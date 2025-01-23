namespace :availabilities do
  desc "Génère des créneaux pour les professionnels pour maintenir 30 jours de disponibilité"
  task generate: :environment do
    Professional.find_each do |professional|
      # Détermine la date la plus avancée actuellement disponible pour chaque jour de la semaine
      availabilities = professional.availabilities
      max_dates = availabilities.group_by { |a| a.start_time.wday }.transform_values { |v| v.max_by(&:start_time).start_time.to_date }
      puts max_dates

      max_dates.each do |wday, date|
        puts date
        puts wday
        i = 1
        while date + i < Date.current + 31
          professional.generate_availabilities_for_one_opening_hour(professional.opening_hours.find_by(day_of_week: wday), professional.interval, date + i)
          i += 1
        end
      end

    end

    puts "Créneaux générés pour tous les professionnels"
  end
end
