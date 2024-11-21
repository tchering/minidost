# frozen_string_literal: true

class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :admin, :boolean
  end
  # Ex:- add_index("admin_users", "username")
  # Ex:- add_index("admin_users", "username")
end
