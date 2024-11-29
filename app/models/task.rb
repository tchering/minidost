# frozen_string_literal: true

class Task < ApplicationRecord
  before_save :normalize_status
  belongs_to :taskable, polymorphic: true
  belongs_to :contractor, class_name: "User", foreign_key: "contractor_id"
  belongs_to :sub_contractor, class_name: "User", foreign_key: "sub_contractor_id", optional: true

  validates :taskable_type, presence: true
  validates :site_name, :street, :city,  :status, presence: true

  # This allows nested attributes for the associated taskable model
  accepts_nested_attributes_for :taskable, allow_destroy: true

  enum status: {
    pending: "pending",
    in_progress: "in progress",
    completed: "completed",
  }

  private

  def normalize_status
    self.status = status.downcase
  end
end
