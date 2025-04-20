require 'open-uri'

require "json"
require "rest-client"


puts "destroy all reviews"
Review.destroy_all

puts "destroy all appointments"
Appointment.destroy_all

puts "destroy all professionals"
Professional.destroy_all

puts "destroy all pets"
Pet.destroy_all

puts "destroy all orders"
Order.destroy_all

puts "destroy all users"
User.destroy_all

puts "destroy all animals"
Animal.destroy_all

puts "destroy all pricing"
Pricing.destroy_all

puts "destroy all pet alerts"
PetAlert.destroy_all


puts "create payment plans"

pricing1 = Pricing.create!(
  title: "Boop 1",
  price: 19.90,
  description: "Un abonnement parfait pour les professionnels indépendants qui veulent gérer leur activité en toute simplicité.",
  capacity: 1,
  stripe_price_id: "price_1R66F8GaLMauVNXcutkmkmJU")
pricing2 = Pricing.create!(
  title: "Boop 5",
  price: 59.90,
  description: "Un abonnement conçu pour les équipes jusqu’à 5 personnes, idéal pour développer votre activité ensemble et optimiser la gestion.",
  capacity: 5,
  stripe_price_id: "price_1R66FkGaLMauVNXcToKWZvNP")
pricing3 = Pricing.create!(
  title: "Boop custom",
  price: 100,
  description: "Vous avez un besoin spécifique ou une équipe plus grande ? Créez une offre sur mesure adaptée à vos exigences et optimisez la gestion de votre activité. Contactez-nous !",
  capacity: 10,)

#puts "create animals"

response = RestClient.get "https://www.la-spa.fr/app/wp-json/spa/v1/animals/search/?api=1"
repos = JSON.parse(response)
repos["results"].each do |animal|
  file = URI.parse(animal["image"]).open
  animal = Animal.new(name: animal["name"],
  species: animal["species_label"],
  races_label: animal["races_label"],
  description: animal["description"]!=nil ? animal["description"].gsub(/<br\s*\/?>|\r\n/, ' ').gsub(/\s+/, ' ').strip : "Non renseigné",
  age: animal["age_number"],
  sex: animal["sex_label"],
  shelter: animal["establishment"]["name"],
  photo: animal["image"])
  animal.save!
end

response = RestClient.get "https://www.la-spa.fr/app/wp-json/spa/v1/animals/search/?api=2"
repos = JSON.parse(response)
repos["results"].each do |animal|
  file = URI.parse(animal["image"]).open
  animal = Animal.new(name: animal["name"],
                species: animal["species_label"],
                races_label: animal["races_label"],
                description: animal["description"]!=nil ? animal["description"].gsub(/<br\s*\/?>|\r\n/, ' ').gsub(/\s+/, ' ').strip : "Non renseigné",
                age: animal["age_number"],
                sex: animal["sex_label"],
                shelter: animal["establishment"]["name"],
                photo: animal["image"])
  animal.save!
end

# # puts "create pet alerts"

# PetAlert.create!(title: "Chat perdu", description: "Mon chat est blanc avec des taches noires. Il s'appelle Félix et il a disparu depuis hier soir. Si vous l'avez vu, merci de me contacter au 06 12 34 56 78", date: "13-01-2025", location: "Centre ville de Nice", contact: "06 12 34 56 78", status: false, photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images/Design%20sans%20titre%20(5).jpg")


# PetAlert.create!(title: "Chien trouvé", description: "J'ai trouvé un chien errant dans le parc de la colline du château. Il est très gentil et bien éduqué. Si vous le reconnaissez, merci de me contacter au 06 12 34 56 78", date: "13-01-2025", location: "Parc de la colline du château", contact: "06 12 34 56 78", status: false, photo: "https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images/Design%20sans%20titre%20(6).jpg")


puts "seed done"
