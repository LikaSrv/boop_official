class OpeningHour < ApplicationRecord
  belongs_to :professional

  before_validation :set_closed_if_empty

  private

  def set_closed_if_empty
    if open_time_morning.blank? && close_time_morning.blank? &&
       open_time_afternoon.blank? && close_time_afternoon.blank?
      self.closed = true
    end
  end

end
