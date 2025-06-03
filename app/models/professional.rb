class Professional < ApplicationRecord

  # validation
  validates :name, :address, :email, :specialty, :description, :capacity, :interval, presence: true
  validates :phone, numericality: { only_integer: true }, presence: true
  validates :specialty, inclusion: {in: ["Vétérinaire", "Toiletteur", "Comportementaliste", "Educateur", "Pension", "Promeneur", "Nutritionniste", "Petsitter"]}
  validate :photo_presence, on: :create
  validate :at_least_one_day_open


  # photo
  has_many_attached :photos

  # associations
  has_many :appointments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :payments
  belongs_to :user
  has_many :opening_hours, dependent: :destroy
  has_many :closing_hours, dependent: :destroy
  accepts_nested_attributes_for :opening_hours, allow_destroy: true

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
    errors.add(:photos, "doit être ajoutée") unless photos.attached?
  end

  private

  def at_least_one_day_open
    valids = opening_hours.reject(&:marked_for_destruction?)
    all_closed = valids.all? do |oh|
      oh.closed || (
        oh.open_time_morning.blank? &&
        oh.close_time_morning.blank? &&
        oh.open_time_afternoon.blank? &&
        oh.close_time_afternoon.blank?
      )
    end

    if all_closed
      errors.add(:base, "Vous devez définir au moins un jour ouvert avec des horaires.")
    end
  end

end
