class CreateTaskApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :task_applications do |t|
      t.references :task, null: false, foreign_key: true
      t.references :subcontractor, null: false, foreign_key: { to_table: :users }
      t.decimal :proposed_price
      t.text :cover_letter
      t.string :application_status
      t.integer :experience
      t.string :completion_timeframe
      t.text :references
      t.string :insurance_status
      t.string :payment_terms
      t.boolean :negotiable
      t.string :skills
      t.text :equipement_owned

      t.timestamps
    end
  end
end
