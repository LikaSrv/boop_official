# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'open-uri'


puts "destroy all reviews"
Review.destroy_all

puts "destroy all appointments"
Appointment.destroy_all

puts "destroy all professionals"
Professional.destroy_all

puts "destroy all users"
User.destroy_all

puts "create users"

user1_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1732869233/samples/landscapes/girl-urban-view.jpg").open
user1 = User.new(email: "user1@test.fr", password: "123456", first_name: "Jean", last_name: "Dupont")
user1.photo.attach(io: user1_photo, filename: 'user1.jpg', content_type: 'image/jpg')
user1.save!

user2_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1732869233/samples/people/smiling-man.jpg").open
user2 = User.new(email: "user2@test.fr", password: "123456", first_name: "Jean", last_name: "Durand")
user2.photo.attach(io: user2_photo, filename: 'user2.jpg', content_type: 'image/jpg')
user2.save!

user3_photo = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1732869242/samples/man-portrait.jpg").open
user3 = User.new(email: "user3@test.fr", password: "123456", first_name: "Jean", last_name: "Duchemin")
user3.photo.attach(io: user3_photo, filename: 'user3.jpg', content_type: 'image/jpg')
user3.save!

puts "create professionals"

vet_file = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/judy-beth-morris-5Bi6MWlWMbw-unsplash_funbpk.jpg").open
professional1 = Professional.new(name: "Jean MEDECIN", address: "Nice", phone: "0123456789", email: "jean.medecin@test.fr", specialty: "Vétérinaire", description: "Vétérinaire depuis 10ans. J'ai soigné tous les animaux.", rating: 5, user_id: user1.id)
professional1.photo.attach(io: vet_file, filename: 'vet.jpg', content_type: 'image/jpg')
professional1.save!

groomer_file = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/reba-spike-PEQIIwnIGdo-unsplash_yfvjlt.jpg").open
professional2 = Professional.new(name: "Jean DUPONT", address: "Paris", phone: "0123456789", email: "jean.dupont@test.fr", specialty: "Toiletteur", description: "Toiletteur depuis 10ans. J'ai nettoyé tous les animaux", rating: 4, user_id: user2.id)
professional2.photo.attach(io: groomer_file, filename: 'groomer.jpg', content_type: 'image/jpg')
professional2.save!

walker_file = URI.parse("https://res.cloudinary.com/dsbteudoz/image/upload/v1733824916/matt-nelson-aI3EBLvcyu4-unsplash_drfsex.jpg").open
professional3 = Professional.new(name: "Jean DURAND", address: "Lyon", phone: "0123456789", email: "jean.durant@test.fr", specialty: "Promeneur", description: "Promeneur depuis 10ans. J'ai promené tous les animaux", rating: 3, user_id: user2.id)
professional3.photo.attach(io: walker_file, filename: 'walker.jpg', content_type: 'image/jpg')
professional3.save!

puts "create reviews"

review1 = Review.create!(content: "Super professionnel", rating: 5, professional_id: professional1.id, user_id: user1.id)
review2 = Review.create!(content: "Super professionnel", rating: 4, professional_id: professional2.id, user_id: user2.id)

puts "seed done"
