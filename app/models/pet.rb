class Pet < ApplicationRecord
  validates :name, :species, :age, :photo, presence: true

  belongs_to :user
  has_many :appointments

  has_one_attached :photo

end
