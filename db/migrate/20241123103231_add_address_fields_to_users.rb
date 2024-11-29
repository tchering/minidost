# frozen_string_literal: true

class AddAddressFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :street, :string
    add_column :users, :area_code, :string
    add_column :users, :city, :string
    add_column :users, :country, :string, default: 'France'

    add_index :users, :city
  end
end
