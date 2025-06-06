class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :appointments, dependent: :destroy
  has_many :professionals, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :pets, dependent: :destroy
  has_many :orders
  has_many :pet_alerts, dependent: :destroy

  validates :first_name, :last_name, presence: true
  has_one_attached :photo
end
