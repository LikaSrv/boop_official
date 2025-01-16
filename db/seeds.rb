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

pricing1 = Pricing.create!(specialty: "Vétérinaire", price: 100)
pricing2 = Pricing.create!(specialty: "Toiletteur", price: 50)
pricing3 = Pricing.create!(specialty: "Promeneur", price: 30)
pricing4 = Pricing.create!(specialty: "Pension", price: 100)
pricing4 = Pricing.create!(specialty: "Petsitter", price: 40)

# puts "create users"

# user1_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1732869233/samples/landscapes/girl-urban-view.jpg").open
# user1 = User.new(email: "user1@test.fr", password: "123456", first_name: "Jean", last_name: "Dupont")
# user1.photo.attach(io: user1_photo, filename: 'user1.jpg', content_type: 'image/jpg')
# user1.save!

# user2_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1732869233/samples/people/smiling-man.jpg").open
# user2 = User.new(email: "user2@test.fr", password: "123456", first_name: "Jean", last_name: "Durand")
# user2.photo.attach(io: user2_photo, filename: 'user2.jpg', content_type: 'image/jpg')
# user2.save!

# lika_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1732869233/samples/landscapes/girl-urban-view.jpg").open
# lika = User.new(email: "lika@test.fr", password: "123456", first_name: "Lika", last_name: "Wagon")
# lika.photo.attach(io: lika_photo, filename: 'lika.jpg', content_type: 'image/jpg')
# lika.save!

# marie_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1732869241/samples/outdoor-woman.jpg").open
# marie = User.new(email: "marie@test.fr", password: "123456", first_name: "Marie", last_name: "Beliben")
# marie.photo.attach(io: marie_photo, filename: 'marie.jpg', content_type: 'image/jpg')
# marie.save!

# puts "create professionals"

# vet_file = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/judy-beth-morris-5Bi6MWlWMbw-unsplash_funbpk.jpg").open
# professional1 = Professional.new(name: "Jean MEDECIN", address: "21 avenue Thiers 06000 Nice", phone: "0123456789", email: "jean.medecin@test.fr", specialty: "Vétérinaire", description: "Vétérinaire depuis 10ans. J'ai soigné tous les animaux.", rating: 5, user_id: user1.id, capacity: 1, start_hour: 9, end_hour: 18, interval: 30)
# professional1.photo.attach(io: vet_file, filename: 'vet.jpg', content_type: 'image/jpg')
# professional1.save!

# groomer_file = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/reba-spike-PEQIIwnIGdo-unsplash_yfvjlt.jpg").open
# professional2 = Professional.new(name: "Michel DUPONT", address: "25 Rue des Renaudes 75017 Paris", phone: "0123456789", email: "jean.dupont@test.fr", specialty: "Toiletteur", description: "Toiletteur depuis 10ans. J'ai nettoyé tous les animaux", rating: 4, user_id: user2.id, capacity: 1, start_hour: 9, end_hour: 18, interval: 60)
# professional2.photo.attach(io: groomer_file, filename: 'groomer.jpg', content_type: 'image/jpg')
# professional2.save!

# walker_file = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/matt-nelson-aI3EBLvcyu4-unsplash_drfsex.jpg").open
# professional3 = Professional.new(name: "Thibault DURAND", address: "25 Rue du Premier Film, 69008 Lyon", phone: "0123456789", email: "jean.durant@test.fr", specialty: "Promeneur", description: "Promeneur depuis 10ans. J'ai promené tous les animaux", rating: 3, user_id: user2.id, capacity: 1, start_hour: 9, end_hour: 18, interval: 120)
# professional3.photo.attach(io: walker_file, filename: 'walker.jpg', content_type: 'image/jpg')
# professional3.save!

# toiletteur_file = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1734622835/slider-formation-toiletteur_tlg2lq.jpg").open
# toiletteur = Professional.new(name: "Lika Le Wagon", address: "21 avenue thiers 06000 Nice", phone: "0123456789", email: "lika_nice@toiletteuse.fr", specialty: "Toiletteur", description: "Toiletteuse depuis 2ans. J'ai nettoyé tous les animaux", rating: 5, user_id: lika.id, capacity: 1, start_hour: 9, end_hour: 18, interval: 90)
# toiletteur.photo.attach(io: toiletteur_file, filename: 'toiletteur.jpg', content_type: 'image/jpg')
# toiletteur.save!

# puts "create reviews"

# Review.create!(content: "Super professionnel", rating: 5, professional_id: professional1.id, user_id: user1.id)
# Review.create!(content: "Super professionnel", rating: 4, professional_id: professional2.id, user_id: user2.id)
# Review.create!(content: "Lika a été absolument fantastique avec mon chien ! Elle a su le mettre en confiance dès le début, et le résultat est impeccable. Son travail est soigné, et on voit qu'elle aime vraiment les animaux. Je recommande vivement ses services !", rating: 5, professional_id: toiletteur.id, user_id: user2.id)
# Review.create!(content: "Lika est incroyable ! Mon chat, pourtant très stressé d'habitude, est ressorti détendu et magnifiquement toiletté. Merci pour votre patience et votre douceur.", rating: 5, professional_id: toiletteur.id, user_id: user1.id)


# kimbo_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1734685816/7C3E2014-E245-4DCE-A02C-5725EE5E81C3_1_105_c_a86eei.jpg").open
# kimbo = Pet.new(name: "Kimbo", species: "American Bully", age: "7 ans", sex: "Mâle", description: "Kimbo est un American Bully de 7 ans, très joueur et affectueux. Il adore les balades et les câlins", user_id: marie.id)
# kimbo.photo.attach(io: kimbo_photo, filename: 'kimbo.jpg', content_type: 'image/jpg')
# kimbo.save!

puts "create animals"

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
