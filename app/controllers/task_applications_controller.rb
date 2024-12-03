class TaskApplicationsController < ApplicationController
  before_action :set_task, only: [:index, :create, :destroy, :review_application, :approve_application, :reject_application]
  before_action :set_application, only: [:review_application, :approve_application, :reject_application]
  before_action :ensure_contractor, only: [:index, :review_application, :approve_application, :reject_application]

  #Contractor can view all applications for a task
  def index
    @applications = @task.task_applications.includes(:sub_contractor)
  end

  #Sub contractor can apply for a task
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

  #Sub contractor can withdraw their application
  def destroy
    @application = @task.task_applications.find_by(subcontractor: current_user)
    if @application&.destroy
      redirect_to @task, notice: t("task.not_interested_message")
    else
      redirect_to @task, alert: t("task.error.not_interested_error_message")
    end
  end

  def review_application
    # @task = Task.find(params[:task_id]) already set in before_action
    # @application = @task.task_applications.find(params[:id]) already set in before_action
    # we need both task.id and application.id becuase in routes we have /:locale)/tasks/:task_id/task_applications/:id/approve(.:format)
    @subcontractor = @application.subcontractor
    @other_applications = @task.task_applications # 1. Start with all applications for this task
      .where.not(id: @application.id) # 2. Exclude the current application
      .includes(:subcontractor)                     # 3. Eager load subcontractor data
  end

  def approve_application
    # Update task with approved subcontractor and price
    @task.update(
      sub_contractor_id: @application.subcontractor_id,
      accepted_price: @application.proposed_price,
      status: "in_progress",
    )
    # Update current application status
    @application.update(
      application_status: "approved",
    )

    # Reject other applications once one is approved
    @task.task_applications
         .where.not(id: @application.id)
         .update_all(application_status: "rejected")
    #once rejected, the application will be marked closed and the subcontractor will be notified

    redirect_to @task, notice: "Subcontractor approved successfully"
  end

  def reject_application
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_application
    @application = @task.task_applications.find(params[:id])
  end

  def ensure_contractor
    unless @task.contractor == current_user
      redirect_to @task, alert: t("task.error.not_contractor_message")
    end
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
