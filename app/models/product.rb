class Product < ApplicationRecord
  has_many :collection_items, dependent: :destroy
  has_many :users, through: :collection_items
  has_many :product_variants, dependent: :destroy

  def self.bulk_existing_urls(urls)
    Product.where(url: urls).pluck(:url)
  end
    
  include PgSearch::Model
  pg_search_scope :search,
                against: {
                  name: 'A',
                  brand: 'A',
                  store: 'A',
                  description: 'B',
                },
                using: {
                  tsearch: {
                    prefix: true,
                    dictionary: 'portuguese',
                    tsvector_column: 'searchable'
                  },
                  trigram: {
                    word_similarity: true
                  }
                },
                ignoring: :accents
end
