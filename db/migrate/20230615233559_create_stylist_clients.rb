class CreateStylistClients < ActiveRecord::Migration[7.0]
  def up
    create_table :stylist_clients do |t|
      t.references :stylist, null: false, index: true, foreign_key: { to_table: :users }
      t.string :name

      t.timestamps
    end

    change_column :stylist_clients, :created_at, :timestamptz
    change_column :stylist_clients, :updated_at, :timestamptz
  end

  def down
    change_column :stylist_clients, :created_at, :datetime
    change_column :stylist_clients, :updated_at, :datetime

    drop_table :stylist_clients
  end
end
