class Order < ApplicationRecord
  belongs_to :user
  belongs_to :pricing
  monetize :amount_cents
end
