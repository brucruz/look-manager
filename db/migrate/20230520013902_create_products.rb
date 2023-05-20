class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.text :name
      t.text :sku
      t.text :brand
      t.text :store
      t.text :url
      t.text :store_url
      t.text :description
      t.decimal :old_price, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2
      t.integer :installment_quantity
      t.decimal :installment_value, precision: 10, scale: 2
      t.boolean :available

      t.timestamps
    end
  end
end
