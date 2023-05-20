json.extract! product, :id, :name, :sku, :brand, :store, :url, :store_url, :description, :old_price, :price, :installment_quantity, :installment_value, :available, :created_at, :updated_at
json.url product_url(product, format: :json)
