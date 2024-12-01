class TaskApplicationsController < ApplicationController
  before_action :set_task, only: [:create, :destroy]
  # before_action :set_application, only: [:approve, :reject]

  def index
    @applications = @task.task_applications.includes(:sub_contractor)
  end

  def create
    if @task.task_applications.exists?(subcontractor: current_user)
      redirect_to @task, alert: t("task.already_interested_message")
      return
    end
    @application = @task.task_applications.build(application_params)
    @application.subcontractor_id = current_user.id
    if @application.save
      redirect_to @task, notice: t("task.interested_message")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @application = @task.task_applications.find_by(subcontractor: current_user)
    if @application&.destroy
      redirect_to @task, notice: t("task.not_interested_message")
    else
      redirect_to @task, alert: t("task.not_interested_error_message")
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def application_params
    params.require(:task_application).permit(
      :proposed_price,
      :cover_letter,
      :experience,
      :completion_timeframe,
      :references,
      :insurance_status,
      :payment_terms,
      :negotiable,
      :skills,
      :equipement_owned
    )
  end
end
