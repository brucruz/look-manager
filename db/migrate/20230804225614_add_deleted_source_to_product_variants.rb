class AddDeletedSourceToProductVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :product_variants, :deleted_source, :boolean, default: false
  end
end
