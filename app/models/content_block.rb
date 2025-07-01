class ContentBlock < ApplicationRecord
  has_one :post, dependent: :destroy

  validates :position, :body, presence: true
end
