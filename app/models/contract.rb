require "prawn"

class Contract < ApplicationRecord
  include DefaultContractTerms

  belongs_to :task
  belongs_to :contractor, class_name: "User"
  belongs_to :subcontractor, class_name: "User"
  has_one_attached :pdf_file

  validates :contract_date, :terms_and_conditions,
            :payment_terms, presence: true
  validates :contract_number, uniqueness: true,
                              allow_nil: true

  enum status: {
    pending: "pending",
    contractor_signed: "contractor_signed",
    subcontractor_signed: "subcontractor_signed",
    completed: "completed",
  }

  before_create :set_initial_status
  after_create :generate_contract_number
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
    self.terms_and_conditions ||= STANDARD_TERMS
    self.payment_terms ||= STANDARD_PAYMENT_TERMS
  end
end
