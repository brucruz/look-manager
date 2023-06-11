class AlterTimestampsColumnType < ActiveRecord::Migration[7.0]
  def change
    change_column :products, :created_at, :timestamptz
    change_column :products, :updated_at, :timestamptz

    change_column :collection_items, :created_at, :timestamptz
    change_column :collection_items, :updated_at, :timestamptz

    change_column :users, :created_at, :timestamptz
    change_column :users, :updated_at, :timestamptz
  end
end
