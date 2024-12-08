# app/controllers/contracts_controller.rb
class ContractsController < ApplicationController
  before_action :set_task
  before_action :authorize_contract_parties
  before_action :authorize_contractor, only: %i[new create]

  def new
    @contract = @task.build_contract(
      contractor: @task.contractor,
      subcontractor: @task.sub_contractor,
      contract_date: Date.current,
      terms_and_conditions: DefaultContractTerms::STANDARD_TERMS,
      payment_terms: DefaultContractTerms::STANDARD_PAYMENT_TERMS,
    )
  end

  def create
    @contract = @task.build_contract(contract_params)
    @contract.contractor = @task.contractor
    @contract.subcontractor = @task.sub_contractor
    @contract.status = "pending"

    if @contract.save
      @contract.generate_pdf
      redirect_to task_contract_path(@task, @contract),
                  notice: t(".success")
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

  def sign_contract
    @contract = @task.contract
    if current_user == @contract.contractor
      @contract.update(signed_by_contractor: true)
    elsif current_user == @contract.subcontractor
      @contract.update(signed_by_subcontractor: true)
    else
      redirect_to task_contract_path(@task, @contract),
                  alert: t("unauthorized")
      return
    end

    if @contract.signed_by_contractor && @contract.signed_by_subcontractor
      @contract.update(status: "completed")
      if @task.status == "approved"
        @task.update(status: "in progress")
      end
    end

    redirect_to task_contract_path(@task, @contract),
                notice: t("contracts.sign.success")
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def authorize_contractor
    unless current_user == @task.contractor
      redirect_to task_path(@task),
                  alert: t("unauthorized")
    end
  end

  def authorize_contract_parties
    unless current_user == @task.contractor || current_user == @task.sub_contractor
      redirect_to task_path(@task),
                  alert: t("unauthorized")
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
