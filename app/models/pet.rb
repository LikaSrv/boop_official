class Pet < ApplicationRecord
  validates :name, :species, :age, :photo, :sex, :races, :birthday, :weight, :spayed_neutered, presence: true

  belongs_to :user
  has_many :appointments
  has_many :vaccinations

  has_one_attached :photo

end
