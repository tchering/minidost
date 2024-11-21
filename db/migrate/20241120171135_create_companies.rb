# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :legal_status
      t.string :company_name
      t.string :siret_number
      t.string :position
      t.string :activity_sector
      t.integer :employees_number
      t.date :establishment_date
      t.decimal :turnover, precision: 10, scale: 2
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :companies, :siret_number, unique: true
    add_index :companies, :company_name
  end
end
