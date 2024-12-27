class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  validates :content, presence: true, length: { min: 1, maximum: 1000 }
  scope :ordered, -> { order(created_at: :asc) }
  
  has_many :notifications, as: :notifiable, dependent: :destroy

  after_create_commit :create_notification

  private

  def create_notification
    recipient = conversation.sender == sender ? conversation.recipient : conversation.sender
    
    # Find or create notification for this sender in this conversation
    notification = Notification.find_or_initialize_by(
      recipient: recipient,
      notifiable_type: "Message",
      read_at: nil,
      action: "new_message",
      sender_id: sender.id,
      conversation_id: conversation.id
    )

    # Update or set the notifiable to the latest message
    notification.notifiable = self
    notification.save

    NotificationChannel.broadcast_notification(notification)
  end
end
