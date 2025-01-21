class PetAlert < ApplicationRecord
  validates :title, :description, :date, :location, presence: true
  has_one_attached :photo

  belongs_to :user, optional: true

  # geocoding
  geocoded_by :location
  after_validation :geocode, if: :will_save_change_to_location?

end
