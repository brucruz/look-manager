class AddSizesToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :sizes, :jsonb, array: true, default: []
  end
end
