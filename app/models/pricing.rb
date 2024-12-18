class Pricing < ApplicationRecord
  monetize :price_cents
end
