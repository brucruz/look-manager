class CreateProductSizes < ActiveRecord::Migration[7.0]
  def change
    create_table :product_sizes do |t|
      t.string :size
      t.boolean :available
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
