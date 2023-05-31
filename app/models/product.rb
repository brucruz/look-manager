class Product < ApplicationRecord
  has_many :collection_items, dependent: :destroy
  has_many :users, through: :collection_items
end
