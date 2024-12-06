class ContractGeneratorService
  def initialize(contract)
    @contract = contract
    @task = contract.task
    # @taskable = @task.taskable
  end

  def generate_pdf
    #! generate pdf here
    pdf = Prawn::Document.new
    generate_header(pdf)
    generate_parties_info(pdf)
    generate_common_task_details(pdf)
    generate_specific_task_details(pdf)
    generate_terms(pdf)
    generate_signatures(pdf)

    @contract.pdf_file.attach(io: StringIO.new(pdf.render), filename: "contract_#{@contract.contract_number}.pdf", content_type: "application/pdf")
  end
end
