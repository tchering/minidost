module ConversationsHelper
  #this is helper method to show notification count for specific conversation
  def unread_notifications_count(conversation, user)
    Notification.where(
      notifiable_type: "Message",
      notifiable_id: conversation.messages.pluck(:id),
      recipient: current_user,
      read_at: nil,
    ).count
  end

  #This is helper method to show notification count for all conversations of current user
  def total_unread_messages_count(user)
    Notification.where(
      recipient: user,
      notifiable_type: "Message",
      read_at: nil,
    ).count
  end
end
