class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :conversations, [:sender_id, :recipient_id], unique: true
    # The index speeds up queries that search by both sender and recipient.
    # No two conversations can have the same sender and recipient.
  end
end
