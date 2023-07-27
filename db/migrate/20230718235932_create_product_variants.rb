require 'rake'

class CreateProductVariants < ActiveRecord::Migration[7.0]
  def self.up
    create_table :product_variants do |t|
      t.string :title
      t.string :full_name
      t.string :description
      t.string :sku
      t.string :url
      t.string :currency
      t.string :images, array: true, default: []
      t.decimal :old_price, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2
      t.integer :installment_quantity
      t.decimal :installment_value, precision: 10, scale: 2
      t.boolean :available
      t.jsonb :sizes, array: true, default: []
      t.references :product, null: false, foreign_key: true

      t.timestamptz :created_at, null: false
      t.timestamptz :updated_at, null: false
    end

    # load rake tasks
    Rails.application.load_tasks

    # run job to move old product data to product variants
    Rake::Task['jobs:move_old_product_data_to_product_variants'].invoke

    # run job to treat existing products data, fixing old data and differentiating from variant's data (skus and names) and adding gender when possible
    Rake::Task['jobs:treat_existing_products_data'].invoke

    # run job to merge products variants into a single product and delete the unused products
    Rake::Task['jobs:merge_products'].invoke
  end

  def self.down
    drop_table :product_variants
  end
end
