# frozen_string_literal: true

class Task < ApplicationRecord
  before_save :normalize_status
  belongs_to :taskable, polymorphic: true
  belongs_to :contractor, class_name: "User", foreign_key: "contractor_id"
  belongs_to :sub_contractor, class_name: "User", foreign_key: "sub_contractor_id", optional: true

  validates :taskable_type, presence: true
  validates :site_name, :street, :city, :status, presence: true

  # This allows nested attributes for the associated taskable model
  accepts_nested_attributes_for :taskable, allow_destroy: true

  enum status: {
    pending: "pending",
    active: "active",
    in_progress: "in progress",
    completed: "completed",
  }

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
end
