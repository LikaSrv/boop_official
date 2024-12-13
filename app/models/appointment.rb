class Appointment < ApplicationRecord
  validates :date, :start_time, :reason, presence: true

  belongs_to :professional
  belongs_to :user

  scope :upcoming, -> { where('date >= ?', Time.now).order(date: :asc) }
end
