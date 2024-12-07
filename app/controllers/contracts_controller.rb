# app/controllers/contracts_controller.rb
class ContractsController < ApplicationController
  before_action :set_task
  before_action :authorize_contractor

  def new
    @contract = @task.build_contract(
      contractor: @task.contractor,
      subcontractor: @task.sub_contractor,
      contract_date: Date.current,
      terms_and_conditions: DefaultContractTerms::STANDARD_TERMS,
      payment_terms: DefaultContractTerms::STANDARD_PAYMENT_TERMS
    )
  end

  def create
    @contract = @task.build_contract(contract_params)
    @contract.contractor = @task.contractor
    @contract.subcontractor = @task.sub_contractor
    @contract.status = 'pending'

    if @contract.save
      @contract.generate_pdf
      redirect_to task_contract_path(@task, @contract),
                  notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @contract = @task.contract
  end

  def download
    @contract = @task.contract
    send_data @contract.pdf_file.download,
              filename: "contract_#{@contract.contract_number}.pdf",
              content_type: "application/pdf"
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def authorize_contractor
    unless current_user == @task.contractor
      redirect_to task_path(@task),
                  alert: t('unauthorized')
    end
  end

  def contract_params
    params.require(:contract).permit(
      :contract_date,
      :terms_and_conditions,
      :payment_terms
    )
  end
end
