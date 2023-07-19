class AddGenderToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :gender, :string
  end
end
