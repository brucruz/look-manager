# frozen_string_literal: true

class ProductCardComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  def main_image
    @product.images.first
  end

  def hover_image
    @product.images.second
  end

  def title
    @product.name
  end

  def description
    @product.description.truncate(100)
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
end
