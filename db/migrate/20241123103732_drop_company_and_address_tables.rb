# frozen_string_literal: true

class DropCompanyAndAddressTables < ActiveRecord::Migration[7.1]
  def up
    drop_table :addresses
    drop_table :companies
  end

  def down
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

    create_table :addresses do |t|
      t.references :company, null: false, foreign_key: true
      t.string :street
      t.string :area_code
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
