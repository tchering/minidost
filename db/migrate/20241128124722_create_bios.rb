class CreateBios < ActiveRecord::Migration[7.1]
  def change
    create_table :bios do |t|
      t.string :text
      t.references :user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
