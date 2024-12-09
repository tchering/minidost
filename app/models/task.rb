# frozen_string_literal: true

class Task < ApplicationRecord
  before_save :normalize_status
  belongs_to :taskable, polymorphic: true
  #! Associations with User model
  belongs_to :contractor, class_name: "User", foreign_key: "contractor_id"
  belongs_to :sub_contractor, class_name: "User", foreign_key: "sub_contractor_id", optional: true

  #! Associations with TaskApplication model
  #track all applications for a task
  has_many :task_applications, dependent: :destroy
  #track all subcontractors who applied to a task
  has_many :interested_sub_contractors, through: :task_applications, source: :subcontractor
  #here source is referencing  { belongs_to :subcontractor} from TaskApplication model

  #! Associations with contract model
  has_one :contract, dependent: :destroy

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
end
