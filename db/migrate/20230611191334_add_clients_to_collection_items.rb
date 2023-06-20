class AddClientsToCollectionItems < ActiveRecord::Migration[7.0]
  def change
    add_column :collection_items, :clients, :string, array: true, default: []
  end
end
