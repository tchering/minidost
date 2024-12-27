class AddSenderAndConversationToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :notifications, :sender, foreign_key: { to_table: :users }
    add_reference :notifications, :conversation, foreign_key: true
  end
end
