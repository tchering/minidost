class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
  has_many :messages, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :recipient_id }
  # uniqueness: { scope: :recipient_id } ensures that a combination of sender_id and recipient_id can only exist once in the database.

  scope :between, ->(sender_id, recipient_id) do
          where("(conversations.sender_id = ? AND conversations.recipient_id = ?) OR
    (conversations.sender_id = ? AND conversations.recipient_id = ?)",
                sender_id, recipient_id, recipient_id, sender_id)
        end
  #! SQL it generates:
  # SELECT "conversations".*
  # FROM "conversations"
  # WHERE (
  #   (conversations.sender_id = 1 AND conversations.recipient_id = 2)
  #   OR
  #   (conversations.sender_id = 2 AND conversations.recipient_id = 1)
  # )

  def participants
    [sender, recipient]
  end

  # conversation = Conversation.first
  # conversation.participants  # Returns [sender, recipient]
end
