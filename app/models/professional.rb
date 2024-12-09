class Professional < ApplicationRecord

  validates :name, :address, :email, :specialty, :description, presence: true
  validates :phone, numericality: { only_integer: true }, presence: true
  validates :email, uniqueness: true
  validates :specialty, inclusion: {in: ["vétérinaire", "toiletteur", "comportementaliste", "educateur", "pension", "promeneur", "nutritionniste", "petsitter", "autre"]},

  # has_one_attached :photo, presence: true

  has_many :appointments, dependent: :destroy
end
