require "prawn"

class Contract < ApplicationRecord
  include DefaultContractTerms

  belongs_to :task
  belongs_to :contractor, class_name: "User"
  belongs_to :subcontractor, class_name: "User"
  has_one_attached :pdf_file
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :contract_date, :terms_and_conditions, :payment_terms, presence: true
  validates :contract_number, uniqueness: true, allow_nil: true
  #! enum is a Rails feature that maps integer values in database to string statuses in code.
  enum status: {
    pending: "pending",
    contractor_signed: "contractor_signed",
    subcontractor_signed: "subcontractor_signed",
    completed: "completed",
  }

  before_create :set_initial_status
  after_create :generate_contract_number
  after_create_commit :notify_subcontractor
  after_update_commit :notify_contractor_signed, if: :saved_change_to_signed_by_contractor?
  after_update_commit :notify_contract_signed, if: :saved_change_to_signed_by_subcontractor?
  before_validation :set_default_terms, on: :create

  def generate_pdf
    pdf = Prawn::Document.new
    decorator = TaskPdfDecoratorFactory.create(task)
    decorator.decorate_pdf(pdf)

    pdf_file.attach(
      io: StringIO.new(pdf.render),
      filename: "contract_#{contract_number}.pdf",
      content_type: "application/pdf",
    )
  end

  private

  def set_initial_status
    self.status ||= :pending
  end

  def generate_contract_number
    number = "CNT-#{Time.current.year}-#{id.to_s.rjust(6, "0")}"
    update_column(:contract_number, number)
  end

  def set_default_terms
    self.terms_and_conditions ||= DefaultContractTerms::STANDARD_TERMS
    self.payment_terms ||= DefaultContractTerms::STANDARD_PAYMENT_TERMS
  end

  def notify_subcontractor
    notification = notifications.create(
      recipient: subcontractor,
      action: "sign_required"
    )
    NotificationChannel.broadcast_notification(notification)
  end

  def notify_contractor_signed
    return unless signed_by_contractor?

    notification = notifications.create(
      recipient: subcontractor,
      action: "contractor_signed"
    )
    NotificationChannel.broadcast_notification(notification)
  end

  def notify_contract_signed
    return unless signed_by_subcontractor?

    notification = notifications.create(
      recipient: contractor,
      action: "contract_signed"
    )
    NotificationChannel.broadcast_notification(notification)
  end
end
