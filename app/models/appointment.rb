class Appointment < ApplicationRecord
  validates :date, :start_time, :reason, presence: true

  belongs_to :professional
  belongs_to :user

  scope :upcoming_and_today, -> {where('start_time >= ?', Time.zone.now).order(start_time: :asc)}
end
