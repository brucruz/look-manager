class Product < ApplicationRecord
  has_many :product_images, dependent: :destroy
  has_many :product_sizes, dependent: :destroy
end
