class Pet < ApplicationRecord
  validates :name, :species, :age, :photo, presence: true

  belongs_to :user

  has_one_attached :photo

end
