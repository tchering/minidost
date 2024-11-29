# frozen_string_literal: true

class AddCompanyFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :legal_status, :string
    add_column :users, :company_name, :string
    add_column :users, :siret_number, :string
    add_column :users, :activity_sector, :string
    add_column :users, :employees_number, :integer
    add_column :users, :establishment_date, :date
    add_column :users, :turnover, :decimal, precision: 10, scale: 2

    add_index :users, :siret_number, unique: true
    add_index :users, :company_name
  end
end
