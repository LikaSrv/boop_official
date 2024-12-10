class Professional < ApplicationRecord

  validates :name, :address, :email, :specialty, :description, presence: true
  validates :phone, numericality: { only_integer: true }, presence: true
  validates :email, uniqueness: true
  validates :specialty, inclusion: {in: ["Vétérinaire", "Toiletteur", "Comportementaliste", "Educateur", "Pension", "Promeneur", "Nutritionniste", "Petsitter", "Autre"]}

  has_one_attached :photo

  has_many :appointments, dependent: :destroy
  has_many :reviews, through: :appointments

  belongs_to :user

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
