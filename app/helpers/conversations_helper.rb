module ConversationsHelper
  def unread_notifications_count(conversation, user)
    Notification.where(
      notifiable_type: "Message",
      notifiable_id: conversation.messages.pluck(:id),
      recipient: current_user,
      read_at: nil,
    ).count
  end
end
