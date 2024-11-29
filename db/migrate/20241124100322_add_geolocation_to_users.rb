# frozen_string_literal: true

class AddGeolocationToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
  end
end
