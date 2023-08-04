class ProductVariant < ApplicationRecord
  belongs_to :product

  def self.bulk_existing_urls(urls)
    ProductVariant.where(url: urls).pluck(:url)
  end
end
