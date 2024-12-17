class Animal < ApplicationRecord

  include PgSearch::Model
  pg_search_scope :search_by_city,
    against: [ :shelter ],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }

end
