# app/decorators/task_pdf_decorator.rb
require "prawn"
require "prawn/table"

class TaskPdfDecorator
  include DefaultContractTerms
  PRIMARY_COLOR = "1266F1"     # Blue
  SECONDARY_COLOR = "B23CFD"   # Purple
  NEUTRAL_GRAY = "6C757D"      # Neutral Gray

  def initialize(task)
    @task = task
    @pdf = Prawn::Document.new(
      page_size: "A4",
      margin: [50, 50, 50, 50],
    )
    @pdf.font "Helvetica"
  end

  def generate_pdf
    decorate_pdf
    finalize_pdf
    @pdf
  end

  private

  def setup_fonts
    # Use Prawn's built-in fonts
    @pdf.font "Helvetica"
  end

  def decorate_pdf(pdf)
    @pdf = pdf
    # Add professional watermark for draft contracts
    add_watermark unless @task.contract.completed?

    # Header with logo placeholders
    generate_letterhead
    generate_header
    generate_contract_details
    generate_parties_info
    generate_task_details
    generate_specific_task_details
    generate_terms_and_conditions
    generate_signatures

    # Add page numbers
    add_page_numbers

    @pdf
  end

  def add_watermark
    @pdf.canvas do
      @pdf.rotate(45, origin: [250, 420]) do
        @pdf.fill_color "CCCCCC"
        @pdf.font("Helvetica") do
          @pdf.text_box "DRAFT",
            at: [0, 0],
            width: 400,
            height: 100,
            font_size: 120,
            align: :center,
            valign: :center,
            rotate: 0,
            overflow: :shrink_to_fit,
            color: "CCCCCC"
        end
      end
    end
  end

  def generate_letterhead
    @pdf.bounding_box([0, @pdf.cursor], width: @pdf.bounds.width) do
      @pdf.fill_color PRIMARY_COLOR
      @pdf.stroke_color PRIMARY_COLOR

      # Company logos or placeholders (mock implementation)
      @pdf.bounding_box([0, @pdf.cursor], width: @pdf.bounds.width / 2) do
        @pdf.text "Contractor Logo", align: :left, size: 10, color: NEUTRAL_GRAY
      end

      @pdf.bounding_box([@pdf.bounds.width / 2, @pdf.cursor], width: @pdf.bounds.width / 2) do
        @pdf.text "Subcontractor Logo", align: :right, size: 10, color: NEUTRAL_GRAY
      end

      @pdf.move_down 20
      @pdf.stroke_horizontal_rule
    end
  end

  def generate_header
    @pdf.move_down 20
    @pdf.fill_color "000000"
    @pdf.font("Helvetica", style: :bold) do
      @pdf.text "SUBCONTRACTOR AGREEMENT",
        size: 22,
        align: :center
    end

    @pdf.move_down 10
    @pdf.font("Helvetica") do
      @pdf.text "Contract Number: #{@task.contract.contract_number}",
        align: :right,
        size: 10,
        color: NEUTRAL_GRAY
      @pdf.text "Date: #{@task.contract.contract_date.strftime("%B %d, %Y")}",
        align: :right,
        size: 10,
        color: NEUTRAL_GRAY
    end
    @pdf.move_down 20
  end

  def generate_contract_details
    details = [
      ["Contract Status", @task.contract.status.titleize],
      ["Contractor Signature", @task.contract.signed_by_contractor ? "Signed" : "Pending"],
      ["Subcontractor Signature", @task.contract.signed_by_subcontractor ? "Signed" : "Pending"],
    ]

    @pdf.font("Helvetica") do
      @pdf.table(details,
                 width: @pdf.bounds.width,
                 cell_style: {
                   padding: [5, 10],
                   border_color: NEUTRAL_GRAY,
                   background_color: "F8F9FA",
                 }) do
        column(0).style(font_style: :bold)
      end
    end
    @pdf.move_down 20
  end

  def generate_parties_info
    parties = [
      [@task.contractor, "Contractor"],
      [@task.sub_contractor, "Subcontractor"],
    ]

    parties.each do |company, role|
      @pdf.font("Helvetica") do
        @pdf.text role, style: :bold, size: 14, color: PRIMARY_COLOR

        details = [
          ["Company Name", company.company_name],
          ["Legal Status", company.legal_status],
          ["SIRET Number", company.siret_number],
          ["Address", company.address],
          ["Contact", company.full_name],
          ["Email", company.email],
          ["Phone", company.phone_number],
        ]

        @pdf.table(details,
                   width: @pdf.bounds.width,
                   cell_style: {
                     padding: [5, 10],
                     border_color: NEUTRAL_GRAY,
                   }) do
          column(0).style(font_style: :bold, background_color: "F8F9FA")
        end
        @pdf.move_down 20
      end
    end
  end

  def generate_task_details
    @pdf.font("Helvetica") do
      @pdf.text "Project Details", style: :bold, size: 16, color: SECONDARY_COLOR

      details = [
        ["Site Name", @task.site_name],
        ["Address", @task.street],
        ["City", @task.city],
        ["Area Code", @task.area_code],
        ["Start Date", @task.start_date&.strftime("%B %d, %Y")],
        ["End Date", @task.end_date&.strftime("%B %d, %Y")],
        ["Proposed Price", ActionController::Base.helpers.number_to_currency(@task.proposed_price, unit: "€")],
        ["Accepted Price", ActionController::Base.helpers.number_to_currency(@task.accepted_price, unit: "€")],
      ]

      @pdf.table(details,
                 width: @pdf.bounds.width,
                 cell_style: {
                   padding: [5, 10],
                   border_color: NEUTRAL_GRAY,
                 }) do
        column(0).style(font_style: :bold, background_color: "F8F9FA")
      end
    end
    @pdf.move_down 20
  end

  def generate_terms_and_conditions
    @pdf.start_new_page
    @pdf.font("Helvetica") do
      @pdf.text "Terms & Conditions", style: :bold, size: 16, color: SECONDARY_COLOR
      @pdf.move_down 10
      @pdf.text @task.contract.terms_and_conditions || DefaultContractTerms::STANDARD_TERMS, size: 10

      @pdf.move_down 20
      @pdf.text "Payment Terms", style: :bold, size: 16, color: SECONDARY_COLOR
      @pdf.move_down 10
      @pdf.text @task.contract.payment_terms || DefaultContractTerms::STANDARD_PAYMENT_TERMS, size: 10
    end
    @pdf.move_down 20
  end

  def generate_signatures
    @pdf.start_new_page
    @pdf.font("Helvetica") do
      @pdf.text "Signatures", style: :bold, size: 16, color: SECONDARY_COLOR
      @pdf.move_down 30

      signature_table = [
        ["For the Contractor", "For the Subcontractor"],
        [@task.contractor.full_name, @task.sub_contractor.full_name],
        [@task.contractor.company_name, @task.sub_contractor.company_name],
        ["Signature: _______________", "Signature: _______________"],
        ["Date: _______________", "Date: _______________"],
      ]

      @pdf.table(signature_table,
                 width: @pdf.bounds.width,
                 cell_style: {
                   align: :center,
                   padding: [10, 10],
                   border_color: "FFFFFF",
                 })
    end
  end

  def add_page_numbers
    @pdf.number_pages "Page <page> of <total>",
      at: [@pdf.bounds.right - 100, 0],
      align: :right,
      size: 10,
      color: NEUTRAL_GRAY
  end

  def finalize_pdf
    @pdf.render_file "contract_#{@task.contract.contract_number}.pdf"
  end

  def generate_specific_task_details
    @pdf.move_down 20
    @pdf.font("Helvetica") do
      @pdf.text "Task-Specific Details", style: :bold, size: 16, color: SECONDARY_COLOR
      @pdf.move_down 10
      @pdf.text "No specific details available.", size: 10, color: NEUTRAL_GRAY
    end
  end

  def generate_legal_terms
    @pdf.start_new_page
    @pdf.font("Helvetica", style: :bold) do
      @pdf.fill_color COLORS[:secondary]
      @pdf.text "Terms & Conditions", size: 18
    end

    @pdf.font("Helvetica") do
      @pdf.text @task.contract.terms_and_conditions || DefaultContractTerms::STANDARD_TERMS,
        size: 10,
        align: :justify
    end
  end

  def generate_financial_terms
    @pdf.move_down 30
    @pdf.font("Helvetica", style: :bold) do
      @pdf.fill_color COLORS[:secondary]
      @pdf.text "Financial Terms", size: 16
    end

    @pdf.font("Helvetica") do
      @pdf.text @task.contract.payment_terms || DefaultContractTerms::STANDARD_PAYMENT_TERMS,
        size: 10,
        align: :justify
    end
  end
end
