# frozen_string_literal: true

class Task < ApplicationRecord
  #! PgSearch is a gem that allows for full-text search in PostgreSQL
  include PgSearch::Model

  pg_search_scope :search_by_term,
    against: {
      taskable_type: "A",
      city: "B",
    },
    using: {
      tsearch: {
        prefix: true,
        dictionary: "french",
        any_word: true,
      },
    }

  before_save :normalize_status
  belongs_to :taskable, polymorphic: true
  #! Associations with User model
  belongs_to :contractor, class_name: "User", foreign_key: "contractor_id"
  belongs_to :sub_contractor, class_name: "User", foreign_key: "sub_contractor_id", optional: true

  #! Associations with TaskApplication model
  #track all applications for a task
  has_many :task_applications, dependent: :destroy
  #track all subcontractors who applied to a task
  has_many :interested_subcontractors, through: :task_applications, source: :sub_contractor
  #here source is referencing  { belongs_to :sub_contractor} from TaskApplication model

  #! Associations with contract model
  has_one :contract, dependent: :destroy

  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :taskable_type, presence: true
  validates :site_name, :street, :city, :status, presence: true

  # This allows nested attributes for the associated taskable model
  accepts_nested_attributes_for :taskable, allow_destroy: true

  #! enum is a Rails feature that maps integer values in database to string statuses in code.
  enum status: {
    pending: "pending",
    active: "active",
    approved: "approved",
    in_progress: "in progress",
    completed: "completed",
  }

  # Add geocoding functionality
  geocoded_by :full_address
  after_validation :geocode, if: :address_changed?

  after_create_commit :notify_new_task

  def add_interested_subcontractor(subcontractor_id)
    self.sub_contractor_list = [] if sub_contractor_list.nil?
    self.sub_contractor_list << subcontractor_id unless sub_contractor_list.include?(subcontractor_id)
    save
  end

  def delete_interested_subcontractor(subcontractor_id)
    return false unless sub_contractor_list.include?(subcontractor_id)
    self.sub_contractor_list.delete(subcontractor_id)
    save
  end

  def select_final_subcontractor(subcontractor_id)
    return false unless sub_contractor_list.include?(subcontractor_id)
    update(sub_contractor_id: subcontractor_id)
    # self.sub_contractor_id = subcontractor_id
    # self.sub_contractor_list = []
    # save
  end

  private

  def normalize_status
    self.status = status.downcase
  end

  def full_address
    [street, city, area_code].compact.join(", ")
  end

  def address_changed?
    street_changed? || city_changed? || area_code_changed?
  end

  def notify_new_task
    # Find all subcontractors to notify about new task
    subcontractors = User.where(position: "sub-contractor")

    subcontractors.each do |subcontractor|
      notification = notifications.create(
        recipient: subcontractor,
        action: "new_task"
      )
      NotificationChannel.broadcast_notification(notification)
    end
  end
end
