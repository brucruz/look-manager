class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.string :brand
      t.string :store
      t.string :url
      t.string :store_url
      t.text :description
      t.string :currency
      t.decimal :old_price, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2
      t.integer :installment_quantity
      t.decimal :installment_value, precision: 10, scale: 2
      t.boolean :available

      t.timestamps
    end

    add_index :products, :url, unique: true
    add_index :products, :name
  end
end
