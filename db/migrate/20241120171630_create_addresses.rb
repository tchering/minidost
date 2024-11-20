class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.references :company, null: false, foreign_key: true
      t.string :street
      t.string :area_code
      t.string :city
      t.string :country, default: "France"
      t.timestamps
    end
  end
end
