class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  validates :content, presence: true, length: { min: 1, maximum: 1000 }
  scope :ordered, -> { order(created_at: :asc) }
  #! Associatin with notification
  has_many :notifications, as: :notifiable, dependent: :destroy

  after_create :create_notification

  private

  def create_notification
    # If current user is the conversation sender, notify the recipient
    # If current user is not the sender, notify the conversation sender
    recipient = conversation.sender == sender ? conversation.recipient : conversation.sender
    notification = notifications.create(recipient: recipient)

    unread_count = Notification.where(
      notifiable_type: "Message",
      notifiable_id: conversation.messages.pluck(:id),
      recipient: recipient,
      read_at: nil,
    ).count

    total_unread_count = Notification.where(
      notifiable_type: "Message",
      recipient: recipient,
      read_at: nil,
    ).count

    ActionCable.server.broadcast(
      "notifications_#{recipient.id}",
      { conversation_id: conversation.id,
        unread_count: unread_count,
        total_unread_count: total_unread_count },
    )
  end
end

# When you create a notification through the association:
# notifications.create(recipient: recipient)
# Rails will automatically set:

# notifiable_id = message's id
# notifiable_type = "Message"
