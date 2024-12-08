# app/decorators/task_pdf_decorator.rb
require "prawn"
require "prawn/table"

class TaskPdfDecorator
  include DefaultContractTerms

  # Modern color scheme
  PRIMARY_COLOR = "2B6CB0"     # Professional Blue
  SECONDARY_COLOR = "4A5568"   # Dark Gray
  NEUTRAL_GRAY = "718096"      # Medium Gray
  BORDER_COLOR = "E2E8F0"      # Light Gray
  SUCCESS_COLOR = "38A169"     # Green
  WARNING_COLOR = "D69E2E"     # Orange

  def initialize(task)
    @task = task
    @pdf = Prawn::Document.new(
      page_size: "A4",
      margin: [50, 50, 50, 50],
      info: {
        Title: "Subcontractor Agreement",
        Author: @task.contractor.company_name,
        Subject: "Contract #{@task.contract.contract_number}",
        Creator: "MiniDost System",
        CreationDate: Time.current,
      },
    )
    setup_fonts
  end

  def generate_pdf
    decorate_pdf(@pdf)
    finalize_pdf
    @pdf
  end

  def decorate_pdf(pdf)
    @pdf = pdf
    add_watermark unless @task.contract.completed?

    #!First page
    generate_header_with_logos
    generate_contract_info
    generate_parties_section
    #!Second page
    generate_project_details #has its onw start_new_page
    #!Third page
    generate_specific_details
    #!Fourth page
    generate_terms_section
    #!Fifth page
    @pdf.start_new_page
    generate_signature_section

    add_footer
    add_page_numbers
    @pdf
  end

  protected

  def generate_specific_details
    @pdf.start_new_page
    @pdf.font("Helvetica") do
      @pdf.text "Task-Specific Details", style: :bold, size: 16, color: SECONDARY_COLOR
      @pdf.move_down 10
      @pdf.text "No specific details available.", size: 10, color: NEUTRAL_GRAY
    end
  end

  private

  def setup_fonts
    @pdf.font "Helvetica"
    @pdf.default_leading 5
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

  def generate_header_with_logos
    @pdf.bounding_box([0, @pdf.cursor], width: @pdf.bounds.width) do
      # Header background
      @pdf.fill_color "F8FAFC"
      @pdf.fill_rectangle [0, @pdf.cursor], @pdf.bounds.width, 100

      # Logo placeholders
      @pdf.bounding_box([0, @pdf.cursor - 10], width: @pdf.bounds.width) do
        # Left logo (Contractor)
        @pdf.bounding_box([0, @pdf.cursor], width: 200, height: 60) do
          if @task.contractor.logo.attached?
            @pdf.image StringIO.new(@task.contractor.logo.download), fit: [180, 50]
          else
            @pdf.text @task.contractor.company_name, size: 16, style: :bold
          end
        end

        # Right logo (Subcontractor)
        @pdf.bounding_box([@pdf.bounds.width - 200, @pdf.cursor], width: 200, height: 60) do
          if @task.sub_contractor.logo.attached?
            @pdf.image StringIO.new(@task.sub_contractor.logo.download), fit: [180, 50]
          else
            @pdf.text @task.sub_contractor.company_name, size: 16, style: :bold, align: :right
          end
        end
      end
    end

    @pdf.move_down 30
    @pdf.text "SUBCONTRACTOR AGREEMENT", size: 24, style: :bold, align: :center
    @pdf.fill_color PRIMARY_COLOR
    @pdf.text "Contract ##{@task.contract.contract_number}", align: :center, size: 14
    @pdf.move_down 20
  end

  def generate_contract_info
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

  def generate_parties_section
    create_section_title("CONTRACTING PARTIES")

    parties_data = [
      ["CONTRACTOR", "SUBCONTRACTOR"],
      [@task.contractor.company_name, @task.sub_contractor.company_name],
      [@task.contractor.legal_status, @task.sub_contractor.legal_status],
      ["SIRET: #{@task.contractor.siret_number}", "SIRET: #{@task.sub_contractor.siret_number}"],
      [@task.contractor.address, @task.sub_contractor.address],
      [@task.contractor.full_name, @task.sub_contractor.full_name],
      [@task.contractor.email, @task.sub_contractor.email],
      [@task.contractor.phone_number, @task.sub_contractor.phone_number],
    ]

    create_comparison_table(parties_data)
  end

  def generate_project_details
    @pdf.start_new_page
    create_section_title("PROJECT SPECIFICATIONS")
    details_data = {
      "Site Information" => {
        "Site Name" => @task.site_name,
        "Address" => @task.street,
        "City" => @task.city,
        "Area Code" => @task.area_code,
      },
      "Timeline" => {
        "Start Date" => @task.start_date&.strftime("%B %d, %Y"),
        "End Date" => @task.end_date&.strftime("%B %d, %Y"),
      },
      "Financial Details" => {
        "Proposed Price" => number_to_currency(@task.proposed_price),
        "Accepted Price" => number_to_currency(@task.accepted_price),
      },
    }

    create_details_tables(details_data)
  end

  def generate_terms_section
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

  def generate_signature_section
    @pdf.start_new_page

    # Set up professional color scheme
    header_color = "333333"  # Dark gray for professional look
    line_color = "CCCCCC"    # Light gray for divider lines

    # Page header with company branding
    @pdf.font("Helvetica") do
      @pdf.text "Agreement Signatures",
                style: :bold,
                size: 18,
                color: header_color,
                align: :center

      @pdf.move_down 20
      @pdf.stroke_horizontal_rule
      @pdf.move_down 20

      # Prepare signature table with enhanced formatting
      signature_table = [
        [
          { content: "Contractor Signature", font_style: :bold },
          { content: "Subcontractor Signature", font_style: :bold },
        ],
        [@task.contractor.full_name, @task.sub_contractor.full_name],
        [@task.contractor.company_name, @task.sub_contractor.company_name],
        [
          { content: "Authorized Signature: ____________________",
            font_style: :italic,
            size: 10 },
          { content: "Authorized Signature: ____________________",
            font_style: :italic,
            size: 10 },
        ],
        [
          { content: "Date: ____________________", size: 10 },
          { content: "Date: ____________________", size: 10 },
        ],
      ]

      @pdf.table(signature_table,
                 width: @pdf.bounds.width,
                 cell_style: {
                   align: :center,
                   padding: [12, 15],
                   border_color: line_color,
                   size: 11,
                   font_style: :normal,
                 },
                 column_widths: {
                   0 => @pdf.bounds.width / 2,
                   1 => @pdf.bounds.width / 2,
                 }) do
        # Add some styling to make it look more professional
        cells.borders = [:bottom]
        row(0).font_style = :bold
        row(0).background_color = "F0F0F0"  # Light gray background for header row
      end

      # Footer note for legal clarity
      @pdf.move_down 20
      @pdf.text "By signing below, both parties acknowledge and agree to the terms outlined in this document.",
                size: 9,
                color: "666666",
                align: :center
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

  def create_section_title(title)
    @pdf.move_down 20
    @pdf.fill_color PRIMARY_COLOR
    @pdf.text title, size: 16, style: :bold
    @pdf.stroke_color BORDER_COLOR
    @pdf.stroke_horizontal_rule
    @pdf.move_down 10
  end

  def create_comparison_table(data)
    @pdf.table(data, width: @pdf.bounds.width) do |t|
      t.cells.padding = 10
      t.cells.borders = [:bottom]
      t.cells.border_color = BORDER_COLOR

      t.row(0).background_color = PRIMARY_COLOR
      t.row(0).text_color = "FFFFFF"
      t.row(0).font_style = :bold

      t.cells.align = :center
      t.cells.inline_format = true
    end
  end

  def add_footer
    @pdf.repeat(:all) do
      @pdf.bounding_box([0, 20], width: @pdf.bounds.width) do
        @pdf.stroke_color BORDER_COLOR
        @pdf.stroke_horizontal_rule
        @pdf.move_down 5
        @pdf.text "Generated by MiniDost System", size: 8, align: :center, color: NEUTRAL_GRAY
      end
    end
  end

  def number_to_currency(amount)
    "€%.2f" % amount if amount
  end

  def create_details_tables(data)
    data.each do |section_title, details|
      @pdf.move_down 10
      @pdf.font("Helvetica", style: :bold) do
        @pdf.text section_title, size: 12, color: SECONDARY_COLOR
      end
      @pdf.move_down 5

      details_array = details.map { |label, value| [label, value || "N/A"] }

      @pdf.table(details_array, width: @pdf.bounds.width) do |t|
        t.cells.padding = [5, 10]
        t.cells.borders = [:bottom]
        t.cells.border_color = BORDER_COLOR
        t.cells.border_width = 0.5

        # Style the labels (first column)
        t.column(0).font_style = :bold
        t.column(0).width = @pdf.bounds.width * 0.3
        t.column(0).text_color = NEUTRAL_GRAY

        # Style the values (second column)
        t.column(1).align = :left

        # Remove borders from empty cells
        t.cells.style do |cell|
          cell.borders = [] if cell.content.nil? || cell.content.empty?
        end
      end
      @pdf.move_down 15
    end
  end
end
