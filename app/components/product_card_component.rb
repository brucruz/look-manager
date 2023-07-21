# frozen_string_literal: true

class ProductCardComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
    @variant = @product.product_variants.first
  end

  def main_image
    @variant.images.first
  end

  def hover_image
    @variant.images.second
  end

  def title
    @product.name
  end

  def description
    @variant.description.truncate(100)
  end

  def id
    @product.id
  end

  def store
    @product.store.upcase
  end

  def brand
    @product.brand.upcase
  end

  def old_price
    number_to_currency(@variant.old_price, precision: 0, unit: 'R$', separator: ',', delimiter: '.')
  end

  def price
    number_to_currency(@variant.price, precision: 0, unit: 'R$', separator: ',', delimiter: '.')
  end
end
