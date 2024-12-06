class CreateContracts < ActiveRecord::Migration[7.1]
  def change
    create_table :contracts do |t|
      t.references :task, null: false, foreign_key: true
      t.references :contractor, null: false, foreign_key: { to_table: :users }
      t.references :subcontractor, null: false, foreign_key: { to_table: :users }
      t.string :contract_number
      t.string :status
      t.date :contract_date
      t.text :terms_and_conditions
      t.text :payment_terms
      t.boolean :signed_by_contractor
      t.boolean :signed_by_subcontractor

      t.timestamps
    end
    add_index :contracts, :contract_number, unique: true
  end
end
