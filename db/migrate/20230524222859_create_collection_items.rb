class CreateCollectionItems < ActiveRecord::Migration[7.0]
  def change
    create_table :collection_items do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :product, null: false, foreign_key: true, index: true
      t.string :color, array: true, default: []
      t.string :palette, array: true, default: []
      t.string :contrast, array: true, default: []
      t.string :style, array: true, default: []
      t.string :body_type, array: true, default: []

      t.timestamps
    end

    add_index :collection_items, [:user_id, :product_id], unique: true
  end
end
