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

  after_create :create_brevo_contact

  private

  def create_brevo_contact
    return unless ENV['BREVO_API_KEY'].present?

    response = BrevoClient.new.create_contact(
      email: email,
      first_name: first_name,
      last_name: last_name
    )
      Rails.logger.info "BREVO RESPONSE: #{response.code} - #{response.body}"

  end
end
