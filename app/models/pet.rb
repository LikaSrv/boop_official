class Pet < ApplicationRecord
  validates :name, :species, :photo, :sex, :races, :birthday, :spayed_neutered, presence: true

  belongs_to :user
  has_many :appointments
  has_many :vaccinations, dependent: :destroy
  accepts_nested_attributes_for :vaccinations, allow_destroy: true
  has_many :weight_histories, dependent: :destroy
  accepts_nested_attributes_for :weight_histories, allow_destroy: true

  has_one_attached :photo

end
