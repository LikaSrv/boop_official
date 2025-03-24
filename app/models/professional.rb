class Professional < ApplicationRecord

  # validation
  validates :name, :address, :email, :specialty, :description, :capacity, :interval, presence: true
  validates :phone, numericality: { only_integer: true }, presence: true
  validates :specialty, inclusion: {in: ["Vétérinaire", "Toiletteur", "Comportementaliste", "Educateur", "Pension", "Promeneur", "Nutritionniste", "Petsitter"]}
  validate :photo_presence, on: :create

  # photo
  has_one_attached :photo

  # associations
  has_many :appointments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :payments
  belongs_to :user
  has_many :opening_hours, dependent: :destroy
  has_many :closing_hours, dependent: :destroy
  accepts_nested_attributes_for :opening_hours, reject_if: :all_blank, allow_destroy: true

  # geocoding
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  # search bar
  include PgSearch::Model
  pg_search_scope :search_by_specialty_and_name,
    against: [ :specialty, :name ],
    using: {
      tsearch: { prefix: true }
    }
  pg_search_scope :search_by_adresse,
  against: [ :address ],
  using: {
    tsearch: { prefix: true }
  }

  def photo_presence
    errors.add(:photo, "doit être ajoutée") unless photo.attached?
  end
end
