class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
  has_many :messages, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :recipient_id }
  # uniqueness: { scope: :recipient_id } ensures that a combination of sender_id and recipient_id can only exist once in the database.

  scope :between, ->(user1, user2) {
          where(sender: [user1, user2], recipient: [user1, user2])
        }
  # This scope helps find conversations between two users regardless of who started it. For example:
  # conversation = Conversation.between(contractor, subcontractor).first
  #! SQL it generates:
  # SELECT * FROM conversations
  # WHERE (sender_id IN (contractor.id, subcontractor.id)
  # AND recipient_id IN (contractor.id, subcontractor.id))

  def participants
    [sender, recipient]
  end

  # conversation = Conversation.first
  # conversation.participants  # Returns [sender, recipient]
end
