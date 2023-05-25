class Product < ApplicationRecord
  has_many :product_images, dependent: :destroy
  has_many :product_sizes, dependent: :destroy
  has_many :user_product_categories, dependent: :destroy
  has_many :users, through: :user_product_categories
end
