class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  validates :content, presence: true, length: { min: 1, maximum: 1000 }
  scope :ordered, -> { order(created_at: :asc) }
end
