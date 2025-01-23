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

  private

  def photo_presence
    errors.add(:photo, "doit être ajoutée") unless photo.attached?
  end

  # generate all availabilities for a professional
  def generate_availabilities(opening_hours, interval, date)

    closed_days = opening_hours.where(closed: true).pluck(:day_of_week)
    if !closed_days.include?(date.wday)
      opening_hour = opening_hours.find_by(day_of_week: date.wday)

      start_time_morning = DateTime.parse("#{date} #{opening_hour.open_time_morning}")
      end_time_morning = DateTime.parse("#{date} #{opening_hour.close_time_morning}")

      while start_time_morning + interval.minutes < end_time_morning
        availability = Availability.new(
          professional: opening_hour.professional,
          start_time: start_time_morning,
          status: 1
        )
        availability.save!

        # Incrémenter start_time de l'intervalle
        start_time_morning += interval.minutes
      end

      start_time_afternoon = DateTime.parse("#{date} #{opening_hour.open_time_afternoon}")
      end_time_afternoon = DateTime.parse("#{date} #{opening_hour.close_time_afternoon}")

      while start_time_afternoon + interval.minutes < end_time_afternoon
        availability = Availability.new(
          professional: opening_hour.professional,
          start_time: start_time_afternoon,
          status: 1
        )
        availability.save!

        # Incrémenter start_time de l'intervalle
        start_time_afternoon += interval.minutes
      end

    end
  end

end
