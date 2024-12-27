class Notification < ApplicationRecord
  #   Rails first looks for a ricipient_id column in the notifications table (by convention)
  # The class_name: "User" tells Rails that the receiver is actually a User model
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end
end
