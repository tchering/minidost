# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :taskable, polymorphic: true, null: false
      t.references :contractor, null: false, foreign_key: { to_table: :users }
      t.references :sub_contractor, null: false, foreign_key: { to_table: :users }
      t.string :site_name
      t.string :street
      t.string :city
      t.string :area_code
      t.decimal :proposed_price, precision: 10, scale: 2
      t.decimal :accepted_price, precision: 10, scale: 2
      t.date :start_date
      t.date :end_date
      t.string :status
      t.string :work_progress
      t.string :billing_process

      t.timestamps
    end
    add_index :tasks, %i[taskable_id taskable_type]
    add_index :tasks, :status
  end
end
