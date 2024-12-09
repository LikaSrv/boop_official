class Professional < ApplicationRecord

  validates :name, :address, :email, :specialty, :description, presence: true
  validates :phone, numericality: { only_integer: true }, presence: true
  validates :email, uniqueness: true
  validates :specialty, inclusion: {in: ["Vétérinaire", "Toiletteur", "Comportementaliste", "Educateur", "Pension", "Promeneur", "Nutritionniste", "Petsitter", "Autre"]}

  has_one_attached :photo

  has_many :appointments, dependent: :destroy
  belongs_to :user
end
