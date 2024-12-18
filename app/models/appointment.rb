class Appointment < ApplicationRecord
  validates :date, :start_time, :reason, :pet_id, presence: true

  belongs_to :professional
  belongs_to :user
  belongs_to :pet

  scope :upcoming_and_today, -> {where('start_time >= ?', Time.zone.now).order(start_time: :asc)}
end
