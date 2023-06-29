class Product < ApplicationRecord
  has_many :collection_items, dependent: :destroy
  has_many :users, through: :collection_items

  include PgSearch::Model
  pg_search_scope :search_product,
                against: {
                  name: 'A',
                  brand: 'A',
                  store: 'A',
                  description: 'B',
                },
                using: {
                  tsearch: {
                    prefix: true,
                    dictionary: 'portuguese'
                  },
                  trigram: {
                    word_similarity: true
                  }
                },
                ignoring: :accents
end
