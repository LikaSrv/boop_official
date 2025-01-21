class Professional < ApplicationRecord

  # validation
  validates :name, :address, :email, :specialty, :description, :photo, :capacity, :interval, presence: true
  validates :phone, numericality: { only_integer: true }, presence: true
  validates :specialty, inclusion: {in: ["Vétérinaire", "Toiletteur", "Comportementaliste", "Educateur", "Pension", "Promeneur", "Nutritionniste", "Petsitter"]}

  # photo
  has_one_attached :photo

  # associations
  has_many :appointments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :payments
  belongs_to :user
  has_many :opening_hours, dependent: :destroy
  accepts_nested_attributes_for :opening_hours, reject_if: :all_blank, allow_destroy: true
  has_many :availabilities, dependent: :destroy

  # geocoding
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  # search bar
  include PgSearch::Model
  pg_search_scope :search_by_specialty_address_and_name,
    against: [ :specialty, :address, :name ],
    using: {
      tsearch: { prefix: true }
    }

end
