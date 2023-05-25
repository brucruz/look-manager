class CreateUserProductCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :user_product_categories do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :product, null: false, foreign_key: true, index: true
      t.string :category
      t.string :color
      t.string :palette
      t.string :contrast
      t.string :style
      t.string :body_type

      t.timestamps
    end

    add_index :user_product_categories, [:user_id, :product_id], unique: true
  end
end
