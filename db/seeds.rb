# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "destroy all"

Review.destroy_all
Appointment.destroy_all
Professional.destroy_all
User.destroy_all

puts "create users"

user1 = User.create!(email: "user1@test.fr", password: "123456")
user2 = User.create!(email: "user2@test.fr", password: "123456")

puts "create professionals"

professional1 = Professional.create!(name: "Jean MEDECIN", address: "Nice", phone: "0123456789", email: "user1@test.fr", specialty: "Vétérinaire", description: "Vétérinaire depuis 10ans. J'ai soigné tous les animaux.", rating: 5, user: user1)
professional2 = Professional.create!(name: "Jean DUPONT", address: "Paris", phone: "0123456789", email: "user2@test.fr", specialty: "Nutritionniste", description: "Nutritionniste depuis 10ans. J'ai sauvé tous les animaux", rating: 4, user: user2)

puts "create appointments"

appointment1 = Appointment.create!(date: "2022-12-12", start_time: "10:00", end_time: "11:00", professional: professional1, user: user1)
appointment2 = Appointment.create!(date: "2022-12-13", start_time: "10:00", end_time: "11:00", professional: professional2, user: user2)

puts "create reviews"

review1 = Review.create!(content: "Super professionnel", rating: 5, appointment: appointment1)
review2 = Review.create!(content: "Super professionnel", rating: 4, appointment: appointment2)

puts "seed done"
