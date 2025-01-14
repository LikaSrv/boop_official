class PetAlert < ApplicationRecord
  validates :title, :description, :date, :location, presence: true
  has_one_attached :photo

  belongs_to :user, optional: true
end
