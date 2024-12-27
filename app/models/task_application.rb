class TaskApplication < ApplicationRecord

  #valid application_status values
  enum application_status: {
         pending: "pending",
         approved: "approved",
         rejected: "rejected",
       }, _default: "pending"

  #validation for application_status
  validates :application_status, inclusion: { in: application_statuses.keys }

  #scope for application_status
  scope :pending, -> { where(application_status: "pending") }
  scope :approved, -> { where(application_status: "approved") }
  scope :rejected, -> { where(application_status: "rejected") }
  #Rails will search for a task_id column in the task_applications table
  belongs_to :task
  #This is trying to say that the subcontractor_id is a foreign key that references the id of the User model
  belongs_to :subcontractor, class_name: "User", foreign_key: "subcontractor_id"

  has_many :notifications, as: :notifiable, dependent: :destroy

  after_create_commit :create_notification

  private

  def create_notification
    notification = notifications.create(
      recipient: task.contractor,
      action: "new_application"
    )
    NotificationChannel.broadcast_notification(notification)
  end
end
